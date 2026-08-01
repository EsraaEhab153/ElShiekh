import SwiftUI
import Common

public struct HomeScreen: View {
    @State private var selectedTab: TabItem = .home
    @State private var isOnline: Bool = false
    @State private var hasIncomingRequest: Bool = false
    @State private var isCallActive: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HomeHeaderView()
                
                StatusCardView(isOnline: $isOnline) { newValue in
                    if newValue {
                        // Simulate receiving a request
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            if isOnline {
                                withAnimation(.spring()) {
                                    hasIncomingRequest = true
                                }
                            }
                        }
                    } else {
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
            VideoCallView()
        }
    }
}

#Preview {
    HomeScreen()
}
