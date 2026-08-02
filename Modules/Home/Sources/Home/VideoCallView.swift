import SwiftUI
import Common

public struct VideoCallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var agoraManager = AgoraManager()
    @State private var isConnecting = true
    
    // Injected parameters
    public var channelName: String
    public var token: String?
    
    public init(channelName: String = "TestChannel", token: String? = nil) {
        self.channelName = channelName
        self.token = token
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isConnecting {
                ConnectingView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isConnecting = false
                                // Initialize Agora after connection overlay finishes
                                agoraManager.initializeAndJoin(channel: channelName, token: token)
                            }
                        }
                    }
            } else {
                ActiveCallView(agoraManager: agoraManager, onEndCall: {
                    agoraManager.leaveChannel()
                    dismiss()
                })
            }
        }
    }
}

#Preview {
    VideoCallView()
}
