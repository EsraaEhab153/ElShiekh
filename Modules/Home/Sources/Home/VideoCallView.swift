import SwiftUI
import Common
import AgoraKit
import Combine

public struct VideoCallView: View {
    @Environment(\.dismiss) private var dismiss
    
    // We instantiate the AgoraSession from AgoraKit
    @State private var session = AgoraSession(appId: "YOUR_AGORA_APP_ID")
    
    @State private var isConnecting = true
    @State private var connectionState: AgoraConnectionState = .disconnected
    @State private var remoteUid: Int? = nil
    
    // Injected parameters
    public var channelName: String
    public var token: String
    
    public init(channelName: String = "TestChannel", token: String = "") {
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
                                // Initialize and join via AgoraSession
                                Task {
                                    do {
                                        try await session.join(channelName: channelName, token: token, uid: 0, includeVideo: true)
                                    } catch {
                                        print("Error joining channel: \(error)")
                                    }
                                }
                            }
                        }
                    }
            } else {
                ActiveCallView(session: session, remoteUid: remoteUid, onEndCall: {
                    Task {
                        try? await session.leave()
                        dismiss()
                    }
                })
            }
        }
        .onReceive(session.connectionStatePublisher) { state in
            self.connectionState = state
        }
        .onReceive(session.remoteUserEventsPublisher) { event in
            switch event {
            case .joined(let user):
                self.remoteUid = user.uid
            case .left(let uid, _):
                if self.remoteUid == uid {
                    self.remoteUid = nil
                }
            default:
                break
            }
        }
    }
}

#Preview {
    VideoCallView()
}
