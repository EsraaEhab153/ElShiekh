//
//  HomeScreen.swift
//  Home
//
//  Provider App — Production Integration
//

import SwiftUI
import Common
import RealtimeKit
import LiveSessionKit
import NetworkKit
import Combine

// MARK: - Incoming Request Payload (from /topic/provider/requests)

public struct IncomingCallRequest: Codable, Sendable {
    public let circleId: String
    public let channelName: String?
    public let token: String?
    public let studentName: String?
}

// MARK: - HomeScreen

public struct HomeScreen: View {

    // MARK: Tab
    @State private var selectedTab: TabItem = .home

    // MARK: Availability State
    @State private var isOnline: Bool = false

    // MARK: Incoming Request State
    @State private var hasIncomingRequest: Bool = false
    @State private var incomingRequest: IncomingCallRequest?

    // MARK: Call State
    @State private var isCallActive: Bool = false
    @State private var isAccepting: Bool = false
    @State private var acceptError: String?

    // MARK: Session Credentials (fetched from REST before presenting call)
    @State private var sessionCircleId: String = ""
    @State private var sessionChannelName: String = ""
    @State private var sessionAgoraToken: String = ""

    // MARK: Dependencies
    @StateObject private var realtimeClient = RealtimeClient()
    private let networkService: NetworkServiceProtocol = NetworkService.shared

    // MARK: Combine
    @State private var cancellables = Set<AnyCancellable>()
    
    // MARK: Dynamic Sheikh ID
    private var currentSheikhId: String {
        return UserDefaults.standard.string(forKey: "loggedInSheikhId") ?? "DEFAULT_ID"
    }

    public init() {}

    // MARK: - Body

    public var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HomeHeaderView()

                StatusCardView(isOnline: $isOnline) { newValue in
                    handleAvailabilityToggle(newValue)
                }

                if hasIncomingRequest {
                    IncomingRequestCardView(
                        onAccept: { acceptIncomingRequest() },
                        onReject: { rejectIncomingRequest() }
                    )
                }

                // Accept Error Banner
                if let error = acceptError {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)
                        Text(error)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.App.destructive)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .transition(.opacity)
                    .onTapGesture { acceptError = nil }
                }

                // Loading Indicator during accept flow
                if isAccepting {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(Color.App.primary)
                        Text("Connecting to session...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.App.primary)
                    }
                    .padding(.top, 16)
                }

                Spacer()

                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        // MARK: - Full Screen Cover → LiveSessionKit
        .fullScreenCover(isPresented: $isCallActive) {
            startLiveSession(
                circleId: sessionCircleId,
                channelName: sessionChannelName,
                agoraToken: sessionAgoraToken,
                uid: 0,
                isHost: true,
                agoraAppId: AppConfig.agoraAppId,
                realtimeClient: realtimeClient,
                networkService: networkService,
                onLeft: { isCallActive = false },
                onSessionEnded: { isCallActive = false }
            )
        }
        // MARK: - Socket Subscription (incoming requests)
        .onReceive(realtimeClient.subscribe(topic: "/topic/sheikhs/\(currentSheikhId)/requests")) { envelope in
            handleIncomingRequestEnvelope(envelope)
        }
    }

    // MARK: - Availability Toggle

    private func handleAvailabilityToggle(_ newValue: Bool) {
        let status: ProviderAvailabilityStatus = newValue ? .available : .offline
        let endpoint = InstantMeetingEndpoints.updateAvailability(status: status)
        
        networkService.requestWithoutData(endpoint)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to update status on backend: \(error.localizedDescription)")
                    self.isOnline = !newValue
                }
            }, receiveValue: { _ in
                if newValue {
                    connectSocket()
                } else {
                    disconnectSocket()
                }
            })
            .store(in: &cancellables)
    }
    
    private func connectSocket() {
        Task {
            let url = URL(string: "wss://almahir-production.up.railway.app/ws")!
            let token = AppRequestInterceptors.shared.tokenProvider?() ?? ""
            do {
                try await realtimeClient.connect(url: url, authToken: token)
                print("STOMP Connected to \(url)")
            } catch {
                print("Failed to connect STOMP: \(error)")
                self.isOnline = false 
            }
        }
    }
    
    private func disconnectSocket() {
        Task {
            await realtimeClient.disconnect()
        }
        withAnimation {
            hasIncomingRequest = false
            incomingRequest = nil
        }
    }

    // MARK: - Incoming Request Handler

    private func handleIncomingRequestEnvelope(_ envelope: RealtimeEventEnvelope) {
        guard let request = try? envelope.decodePayload(as: IncomingCallRequest.self) else {
            return
        }
        incomingRequest = request
        withAnimation(.spring()) {
            hasIncomingRequest = true
        }
    }

    // MARK: - Accept Flow (REST → STOMP → RTC)

    private func acceptIncomingRequest() {
        guard let request = incomingRequest else { return }

        isAccepting = true
        acceptError = nil

        // STEP 1: Fetch session credentials from REST API
        networkService.request(LiveSessionEndpoints.getCircleDetail(circleId: request.circleId))
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [self] completion in
                    if case .failure(let error) = completion {
                        isAccepting = false
                        acceptError = "Failed to fetch session: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [self] (detail: CircleDetailDTO) in
                    let channelName = detail.channelName ?? request.channelName ?? ""
                    let agoraToken = detail.resolvedToken ?? request.token ?? ""

                    guard !channelName.isEmpty, !agoraToken.isEmpty else {
                        isAccepting = false
                        acceptError = "Invalid session credentials received from server."
                        return
                    }

                    // Store resolved credentials
                    sessionCircleId = request.circleId
                    sessionChannelName = channelName
                    sessionAgoraToken = agoraToken

                    // STEP 2 & 3: Present LiveSessionKit
                    isAccepting = false
                    hasIncomingRequest = false
                    incomingRequest = nil
                    isCallActive = true
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Reject Flow

    private func rejectIncomingRequest() {
        // لو الباك إند محتاج إنك تبعتيله رفض، هنستخدم الـ Endpoint هنا
        guard let request = incomingRequest else { return }
        
        let endpoint = InstantMeetingEndpoints.declineRequest(requestId: request.circleId)
        networkService.requestWithoutData(endpoint)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                print("Request declined successfully on backend.")
            })
            .store(in: &cancellables)
            
        withAnimation {
            hasIncomingRequest = false
            incomingRequest = nil
        }
    }
}
