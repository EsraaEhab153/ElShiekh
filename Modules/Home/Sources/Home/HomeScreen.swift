import SwiftUI
import Common
import RealtimeKit
import Combine

struct CallRequest: Codable {
    let channelName: String
    let token: String
}

public struct HomeScreen: View {
    @State private var selectedTab: TabItem = .home
    @State private var isOnline: Bool = false
    @State private var hasIncomingRequest: Bool = false
    @State private var isCallActive: Bool = false
    
    // RealtimeKit Integration
    @StateObject private var realtimeClient = RealtimeClient()
    @State private var currentChannelName: String = ""
    @State private var currentToken: String = ""
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HomeHeaderView()
                
                StatusCardView(isOnline: $isOnline) { newValue in
                    if newValue {
                        // Connect to RealtimeKit
                        Task {
                            let url = URL(string: "wss://placeholder-socket-url.com")!
                            try? await realtimeClient.connect(url: url, authToken: "PLACEHOLDER_TOKEN")
                        }
                    } else {
                        // Disconnect from RealtimeKit
                        Task {
                            await realtimeClient.disconnect()
                        }
                        withAnimation {
                            hasIncomingRequest = false
                        }
                    }
                }
                
                if hasIncomingRequest {
                    IncomingRequestCardView(
                        onAccept: {
                            isCallActive = true
                            hasIncomingRequest = false
                        },
                        onReject: {
                            withAnimation {
                                hasIncomingRequest = false
                            }
                        }
                    )
                }
                
                Spacer()
                
                // Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .fullScreenCover(isPresented: $isCallActive) {
            VideoCallView(channelName: currentChannelName, token: currentToken)
        }
        // Listen to incoming requests via RealtimeKit when connected
        .onReceive(realtimeClient.subscribe(topic: "/topic/provider/requests")) { envelope in
            if let request = try? envelope.decodePayload(as: CallRequest.self) {
                currentChannelName = request.channelName
                currentToken = request.token
                withAnimation(.spring()) {
                    hasIncomingRequest = true
                }
            }
        }
    }
}

#Preview {
    HomeScreen()
}
