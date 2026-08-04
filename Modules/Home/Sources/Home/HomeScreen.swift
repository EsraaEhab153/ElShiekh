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

// MARK: - Incoming Request Payload (from /topic/provider/requests)

public struct IncomingCallRequest: Codable, Sendable {
    public let circleId: String
    public let channelName: String?
    public let token: String?
    public let studentName: String?
}

// MARK: - HomeScreen

public struct HomeScreen: View {

    // MARK: - ViewModel (single source of truth for all business logic)
    @StateObject private var viewModel = HomeViewModel()

    // MARK: - Pure UI State (kept in View — no business logic)
    @State private var selectedTab: TabItem = .home

    public init() {}

    // MARK: - Body

    public var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HomeHeaderView()

                StatusCardView(isOnline: $viewModel.isOnline) { newValue in
                    viewModel.handleAvailabilityToggle(newValue)
                }

                if viewModel.hasIncomingRequest {
                    IncomingRequestCardView(
                        onAccept: { viewModel.acceptIncomingRequest() },
                        onReject: { viewModel.rejectIncomingRequest() }
                    )
                }

                // Accept Error Banner
                if let error = viewModel.acceptError {
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
                    .onTapGesture { viewModel.acceptError = nil }
                }

                // Loading Indicator during accept flow
                if viewModel.isAccepting {
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
        .fullScreenCover(isPresented: $viewModel.isCallActive) {
            startLiveSession(
                circleId: viewModel.sessionCircleId,
                channelName: viewModel.sessionChannelName,
                agoraToken: viewModel.sessionAgoraToken,
                uid: 0,
                isHost: true,
                agoraAppId: AppConfig.agoraAppId,
                realtimeClient: viewModel.realtimeClient,
                networkService: viewModel.networkService,
                onLeft: { viewModel.endCall() },
                onSessionEnded: { viewModel.endCall() }
            )
        }
    }
}
