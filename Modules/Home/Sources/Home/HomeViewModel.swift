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

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published State

    /// Availability toggle state — driven by the Toggle in StatusCardView
    @Published var isOnline: Bool = false

    /// Incoming request state
    @Published var hasIncomingRequest: Bool = false
    @Published var incomingRequest: IncomingCallRequest?

    /// Call state
    @Published var isCallActive: Bool = false
    @Published var isAccepting: Bool = false
    @Published var acceptError: String?

    /// Session credentials (fetched from REST before presenting call)
    @Published var sessionCircleId: String = ""
    @Published var sessionChannelName: String = ""
    @Published var sessionAgoraToken: String = ""

    // MARK: - Dependencies

    let realtimeClient = RealtimeClient()
    let networkService: NetworkServiceProtocol = NetworkService.shared

    // MARK: - Combine
    // FIX: Stored as a regular class property — never destroyed by SwiftUI struct re-creation.
    // This was the #1 root cause: @State var cancellables on a struct silently cancelled subscriptions.
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Dynamic Sheikh ID

//    var currentSheikhId: String {
//        UserDefaults.standard.string(forKey: "loggedInSheikhId") ?? "DEFAULT_ID"
//    }
    var currentSheikhId: String {
        return "aa6f3d89-c484-47ec-8abd-001967908123"
    }
    //56888525-b97e-4fde-8ed2-f5b95b85e4c3

    // MARK: - Init

    init() {
        print("🏠 [HomeVM] init — sheikhId=\(currentSheikhId)")
        setupConnectionStateObserver()
        setupIncomingRequestSubscription()
    }

    // MARK: - Connection State Observer
    // FIX: Observes connectionStatePublisher to auto-revert toggle on async WebSocket failures.
    // Previously, nothing observed connection state, so async failures were completely silent.

    private func setupConnectionStateObserver() {
        realtimeClient.connectionStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                print("🔌 [HomeVM] Connection state → \(state)")
                switch state {
                case .failed(let error):
                    print("🔌 [HomeVM] Connection FAILED: \(error)")
                    if self.isOnline {
                        print("🔌 [HomeVM] Auto-reverting isOnline → false")
                        self.isOnline = false
                    }
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
        let topic = "/topic/sheikhs/\(currentSheikhId)/requests"
        print("📡 [HomeVM] Subscribing to topic: \(topic)")

        realtimeClient.subscribe(topic: topic)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] envelope in
                self?.handleIncomingRequestEnvelope(envelope)
            }
            .store(in: &cancellables)
    }

    // MARK: - Availability Toggle

    func handleAvailabilityToggle(_ newValue: Bool) {
        print("🔄 [HomeVM] handleAvailabilityToggle(\(newValue)), current isOnline=\(isOnline)")

        // Optimistic UI update — the Toggle already shows the new value via the custom Binding.
        // We set it here so the ViewModel state is consistent.
        isOnline = newValue

        let status: ProviderAvailabilityStatus = newValue ? .available : .offline
        let endpoint = InstantMeetingEndpoints.updateAvailability(status: status)

        print("🔄 [HomeVM] API call → updateAvailability(\(status.rawValue))")

        networkService.requestWithoutData(endpoint)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else {
                    print("🔄 [HomeVM] ⚠️ Self deallocated in API completion")
                    return
                }
                switch completion {
                case .finished:
                    print("🔄 [HomeVM] API subscription completed normally")
                case .failure(let error):
                    print("🔄 [HomeVM] ❌ API FAILED: \(error.localizedDescription)")
                    print("🔄 [HomeVM] Reverting isOnline → \(!newValue)")
                    // FIX: This revert does NOT re-trigger handleAvailabilityToggle because
                    // StatusCardView uses a custom Binding whose setter only fires on USER taps.
                    self.isOnline = !newValue
                }
            }, receiveValue: { [weak self] success in
                guard let self else { return }
                print("🔄 [HomeVM] ✅ API success, response=\(success)")
                if newValue {
                    print("🔄 [HomeVM] → Connecting socket...")
                    self.connectSocket()
                } else {
                    print("🔄 [HomeVM] → Disconnecting socket...")
                    self.disconnectSocket()
                }
            })
            .store(in: &cancellables)
    }

    // MARK: - Socket Management

    private func connectSocket() {
        Task {
            let url = URL(string: "wss://almahir-production.up.railway.app/ws/websocket")!
            let token = AppRequestInterceptors.shared.tokenProvider?() ?? ""
            print("🔌 [HomeVM] connectSocket — url=\(url), tokenEmpty=\(token.isEmpty)")

            do {
                try await realtimeClient.connect(url: url, authToken: token)
                print("🔌 [HomeVM] connect() returned (non-blocking handshake initiated)")
                self.fetchPendingRequests()
            } catch {
                print("🔌 [HomeVM] ❌ connect() threw: \(error)")
                // The connectionStatePublisher observer handles reverting isOnline
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
        guard let request = try? envelope.decodePayload(as: IncomingCallRequest.self) else {
            print("📨 [HomeVM] ❌ Failed to decode IncomingCallRequest from payload")
            return
        }
        print("📨 [HomeVM] ✅ Decoded request: circleId=\(request.circleId), student=\(request.studentName ?? "nil")")
        incomingRequest = request
        withAnimation(.spring()) {
            hasIncomingRequest = true
        }
    }

    // MARK: - Accept Flow (REST → Credentials → RTC)

    func acceptIncomingRequest() {
        guard let request = incomingRequest else {
            print("📞 [HomeVM] acceptIncomingRequest called but incomingRequest is nil")
            return
        }

        print("📞 [HomeVM] Accepting request: circleId=\(request.circleId)")
        isAccepting = true
        acceptError = nil

        let endpoint = InstantMeetingEndpoints.acceptRequest(requestId: request.circleId)
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
                    self.sessionCircleId = request.circleId
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
        guard let request = incomingRequest else {
            print("📞 [HomeVM] rejectIncomingRequest called but incomingRequest is nil")
            return
        }

        print("📞 [HomeVM] Rejecting request: circleId=\(request.circleId)")

        let endpoint = InstantMeetingEndpoints.declineRequest(requestId: request.circleId)
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

        networkService.request(endpoint)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("📋 [HomeVM] ❌ Fetch pending failed: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] (requests: [SheikhMeetingRequestEvent]) in
                guard let self else { return }
                print("📋 [HomeVM] ✅ Received \(requests.count) pending request(s)")
                if let firstRequest = requests.first {
                    let mappedRequest = IncomingCallRequest(
                        circleId: firstRequest.requestId,
                        channelName: "",
                        token: "",
                        studentName: firstRequest.studentName ?? "طالب"
                    )

                    self.incomingRequest = mappedRequest
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
        isCallActive = false
    }
}
