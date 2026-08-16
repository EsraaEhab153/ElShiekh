//
//  HomeViewModel.swift
//  Home
//
//  Provider App — ViewModel for HomeScreen
//  Manages availability toggle, STOMP connection, and incoming requests.
//

import SwiftUI
import Combine
import RealtimeKit
import NetworkKit
import LiveSessionKit
import Common
import UserNotifications
import ActivityKit

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published State

    /// Availability toggle state — driven by the Toggle in StatusCardView
    @Published var isOnline: Bool = false

    /// Incoming request state
    @Published var hasIncomingRequest: Bool = false
    @Published var incomingRequest: IncomingCallRequest?
    @Published var currentLiveActivity: Activity<CallAttributes>?

    /// Call state
    @Published var isCallActive: Bool = false
    @Published var isAccepting: Bool = false
    @Published var acceptError: String?

    /// Session credentials (fetched from REST before presenting call)
    @Published var sessionRequestId: String = "" // تم تغييرها من sessionCircleId لـ sessionRequestId
    @Published var sessionChannelName: String = ""
    @Published var sessionAgoraToken: String = ""

    // MARK: - Dependencies

    let realtimeClient = RealtimeClient()
    let networkService: NetworkServiceProtocol = NetworkService.shared

    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()
    private var requestSubscription: AnyCancellable?
    // MARK: - Dynamic Sheikh ID

    var currentSheikhId: String {
        // Dynamically resolved from the authenticated session.
        // SessionManager is populated by AuthManager on login/silentLogin.
        return SessionManager.shared.currentUser?.id
            ?? "482fbea4-eb85-4474-aae6-0cbf7649ac2f" // fallback for dev/testing only
    }

    // MARK: - Init

    init() {
        print("🏠 [HomeVM] init — sheikhId=\(currentSheikhId)")
        setupConnectionStateObserver()
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.publisher(for: NSNotification.Name("AnswerCall"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self = self,
                      let reqId = notification.userInfo?["requestId"] as? String,
                      self.incomingRequest?.requestId == reqId else { return }
                self.acceptIncomingRequest()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: NSNotification.Name("DeclineCall"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self = self,
                      let reqId = notification.userInfo?["requestId"] as? String,
                      self.incomingRequest?.requestId == reqId else { return }
                self.rejectIncomingRequest()
            }
            .store(in: &cancellables)
    }

    // MARK: - Connection State Observer

    private func setupConnectionStateObserver() {
        realtimeClient.connectionStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                print("🔌 [HomeVM] Connection state → \(state)")
                switch state {
                case .failed(let error):
                    print("🔌 [HomeVM] Connection FAILED: \(error)")
                    // Commented out to prevent the toggle from turning off when backgrounded
                    // if self.isOnline {
                    //     print("🔌 [HomeVM] Auto-reverting isOnline → false")
                    //     self.isOnline = false
                    // }
                case .disconnected:
                    print("🔌 [HomeVM] State: Disconnected")
                case .connected:
                    print("🔌 [HomeVM] State: Connected ✅")
                case .connecting:
                    print("🔌 [HomeVM] State: Connecting...")
                case .reconnecting(let attempt):
                    print("🔌 [HomeVM] State: Reconnecting (attempt \(attempt))...")
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Incoming Request Subscription

    private func setupIncomingRequestSubscription() {
        requestSubscription?.cancel()
        
        let topic = "/topic/sheikhs/\(currentSheikhId)/requests"
        print("📡 [HomeVM] Subscribing to topic: \(topic)")

        requestSubscription = realtimeClient.subscribe(topic: topic)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] envelope in
                self?.handleIncomingRequestEnvelope(envelope)
            }
    }

    // MARK: - Availability Toggle

    func handleAvailabilityToggle(_ newValue: Bool) {
        print("🔄 [HomeVM] handleAvailabilityToggle(\(newValue)), current isOnline=\(isOnline)")

        isOnline = newValue
        let status: ProviderAvailabilityStatus = newValue ? .available : .offline
        let endpoint = InstantMeetingEndpoints.updateAvailability(status: status)

        print("🔄 [HomeVM] API call → updateAvailability(\(status.rawValue))")

        networkService.requestWithoutData(endpoint)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    print("🔄 [HomeVM] API subscription completed normally")
                case .failure(let error):
                    print("🔄 [HomeVM] ❌ API FAILED: \(error.localizedDescription)")
                    print("🔄 [HomeVM] Reverting isOnline → \(!newValue)")
                    self.isOnline = !newValue
                }
            }, receiveValue: { [weak self] success in
                guard let self else { return }
                print("🔄 [HomeVM] ✅ API success, response=\(success)")
                if newValue {
                    print("🔄 [HomeVM] → Connecting socket...")
                    BackgroundAudioManager.shared.start()
                    self.connectSocket()
                } else {
                    print("🔄 [HomeVM] → Disconnecting socket...")
                    BackgroundAudioManager.shared.stop()
                    self.disconnectSocket()
                }
            })
            .store(in: &cancellables)
    }

    // MARK: - Socket Management

    private func connectSocket() {
        Task {
            let url = URL(string: "wss://almahir-production-6f98.up.railway.app/ws/websocket")!
            let token = AppRequestInterceptors.shared.tokenProvider?() ?? ""
            print("🔌 [HomeVM] connectSocket — url=\(url), tokenEmpty=\(token.isEmpty)")

            do {
                try await realtimeClient.connect(url: url, authToken: token)
                print("🔌 [HomeVM] connect() returned (non-blocking handshake initiated)")
                
                self.setupIncomingRequestSubscription()
                self.fetchPendingRequests()
                
            } catch {
                print("🔌 [HomeVM] ❌ connect() threw: \(error)")
            }
        }
    }

    private func disconnectSocket() {
        Task {
            await realtimeClient.disconnect()
            print("🔌 [HomeVM] disconnect() completed")
        }
        withAnimation {
            hasIncomingRequest = false
            incomingRequest = nil
        }
    }

    // MARK: - Incoming Request Handler

    private func handleIncomingRequestEnvelope(_ envelope: RealtimeEventEnvelope) {
            print("📨 [HomeVM] Received envelope, eventType=\(envelope.eventType)")
            
            if envelope.eventType == "SHEIKH_MEETING_REQUEST_REMOVED" || envelope.eventType == "SHEIKH_MEETING_REQUEST_CANCELLED" {
                print("📨 [HomeVM] 🚫 Request removed by student. Hiding UI.")
                withAnimation(.spring()) {
                    self.hasIncomingRequest = false
                    self.incomingRequest = nil
                }
                return
            }
            
            do {
                let request = try envelope.decodePayload(as: IncomingCallRequest.self)
                print("📨 [HomeVM] ✅ Decoded request: requestId=\(request.requestId), student=\(request.studentName ?? "مجهول")")
                
                // Prevent UI from showing a new request if a call is already active
                guard !self.isCallActive else {
                    print("📨 [HomeVM] ⚠️ Ignored request because provider is currently in a call.")
                    return
                }
                
                self.incomingRequest = request
                withAnimation(.spring()) {
                    self.hasIncomingRequest = true
                }
                
                // Check app state to handle foreground vs background
                if UIApplication.shared.applicationState == .active {
                    print("📨 [HomeVM] App is active. Showing Live Activity.")
                    self.showLiveActivity(for: request)
                } else {
                    print("📨 [HomeVM] App is in background. Showing Local Notification.")
                    self.showLocalNotification(for: request)
                }
                
            } catch {
                print("📨 [HomeVM] ❌ Decode error details: \(error)")
            }
        }
        
    private func showLiveActivity(for request: IncomingCallRequest) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled.")
            return
        }
        
        let attributes = CallAttributes(
            callerName: request.studentName ?? "Student",
            requestId: request.requestId
        )
        let contentState = CallAttributes.ContentState(status: "Ringing...")
        
        do {
            currentLiveActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )
            print("✅ Live Activity started successfully!")
        } catch {
            print("❌ Error starting Live Activity: \(error.localizedDescription)")
        }
    }

    private func showLocalNotification(for request: IncomingCallRequest) {
        let content = UNMutableNotificationContent()
        content.title = "Incoming Call"
        content.body = "\(request.studentName ?? "Student") is calling you..."
        content.categoryIdentifier = "INCOMING_CALL"
        content.sound = UNNotificationSound.default
        content.userInfo = ["requestId": request.requestId]
        
        let req = UNNotificationRequest(
            identifier: request.requestId,
            content: content,
            trigger: nil // deliver immediately
        )
        
        UNUserNotificationCenter.current().add(req) { error in
            if let error = error {
                print("Error pushing local notification: \(error.localizedDescription)")
            }
        }
    }

    func endLiveActivity() {
        Task {
            let finalState = CallAttributes.ContentState(status: "Ended")
            let content = ActivityContent(state: finalState, staleDate: nil)
            
            await currentLiveActivity?.end(content, dismissalPolicy: .immediate)
            currentLiveActivity = nil
        }
    }

    // MARK: - Accept Flow

    func acceptIncomingRequest() {
        guard let request = incomingRequest else { return }

        print("📞 [HomeVM] Accepting request: requestId=\(request.requestId)")
        isAccepting = true
        acceptError = nil
        endLiveActivity()

        let endpoint = InstantMeetingEndpoints.acceptRequest(requestId: request.requestId)
        networkService.request(endpoint)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("📞 [HomeVM] ❌ acceptRequest failed: \(error.localizedDescription)")
                        self?.isAccepting = false
                        self?.acceptError = "Failed to accept session: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] (response: AcceptResponse) in
                    guard let self else { return }
                    let channelName = response.channelName
                    let agoraToken = response.agoraToken

                    print("📞 [HomeVM] AcceptResponse — channel=\"\(channelName)\", tokenEmpty=\(agoraToken.isEmpty)")

                    guard !channelName.isEmpty, !agoraToken.isEmpty else {
                        print("📞 [HomeVM] ❌ Invalid credentials")
                        self.isAccepting = false
                        self.acceptError = "Invalid session credentials received from server."
                        return
                    }

                    // Store resolved credentials
                    self.sessionRequestId = request.requestId
                    self.sessionChannelName = channelName
                    self.sessionAgoraToken = agoraToken

                    // Present LiveSessionKit
                    self.isAccepting = false
                    self.hasIncomingRequest = false
                    self.incomingRequest = nil
                    self.isCallActive = true
                    print("📞 [HomeVM] ✅ Session ready — presenting live session")
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Reject Flow

    func rejectIncomingRequest() {
        guard let request = incomingRequest else { return }

        print("📞 [HomeVM] Rejecting request: requestId=\(request.requestId)")
        endLiveActivity()

        let endpoint = InstantMeetingEndpoints.declineRequest(requestId: request.requestId)
        networkService.requestWithoutData(endpoint)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("📞 [HomeVM] ❌ Decline API failed: \(error.localizedDescription)")
                }
            }, receiveValue: { _ in
                print("📞 [HomeVM] ✅ Request declined on backend")
            })
            .store(in: &cancellables)

        withAnimation {
            hasIncomingRequest = false
            incomingRequest = nil
        }
    }

    // MARK: - Fetch Pending Requests

    private func fetchPendingRequests() {
        print("📋 [HomeVM] Fetching pending requests...")
        let endpoint = InstantMeetingEndpoints.getPendingRequests

        // NetworkService automatically decodes APISuccessResponse<T> and returns the `data` part.
        // Therefore, we only need to ask for `PendingRequestsData`.
        networkService.request(endpoint)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("📋 [HomeVM] ❌ Fetch pending failed: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] (response: PendingRequestsData) in
                guard let self else { return }
                
                let requests = response.content
                print("📋 [HomeVM] ✅ Received \(requests.count) pending request(s)")
                
                if let firstRequest = requests.first {
                    self.incomingRequest = firstRequest
                    withAnimation(.spring()) {
                        self.hasIncomingRequest = true
                    }
                    print("📋 [HomeVM] Showing pending request: \(firstRequest.requestId)")
                }
            })
            .store(in: &cancellables)
    }

    // MARK: - Call Lifecycle

    func endCall() {
        print("📞 [HomeVM] endCall()")
        
        // 1. Reset UI State completely
        isCallActive = false
        hasIncomingRequest = false
        incomingRequest = nil
        endLiveActivity()
        
        let endedRequestId = sessionRequestId
        sessionRequestId = ""
        sessionChannelName = ""
        sessionAgoraToken = ""
        
        // 2. Sync Backend: Notify the server the meeting has ended
        if !endedRequestId.isEmpty {
            print("📞 [HomeVM] Notifying backend that meeting \(endedRequestId) has ended")
            let endEndpoint = InstantMeetingEndpoints.endMeeting(requestId: endedRequestId)
            networkService.requestWithoutData(endEndpoint)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                    print("📞 [HomeVM] ✅ Meeting effectively ended on backend")
                })
                .store(in: &cancellables)
        }
        
        // 3. Reset Availability to AVAILABLE (if they are online) so they can receive new calls
        if isOnline {
            print("📞 [HomeVM] Syncing availability back to AVAILABLE")
            let availEndpoint = InstantMeetingEndpoints.updateAvailability(status: .available)
            networkService.requestWithoutData(availEndpoint)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] _ in
                    print("📞 [HomeVM] ✅ Availability synced to AVAILABLE")
                    // 4. Fetch any pending requests that might have been queued while they were busy
                    self?.fetchPendingRequests()
                })
                .store(in: &cancellables)
        }
    }
}
