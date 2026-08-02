import SwiftUI
import Common
import AgoraKit

public struct ConnectingView: View {
    public init() {}
    
    public var body: some View {
        Text("...Connecting")
            .font(.system(size: 24, weight: .semibold))
            .foregroundColor(.white)
    }
}

public struct ActiveCallView: View {
    var session: AgoraSessionManaging
    var remoteUid: Int?
    var onEndCall: () -> Void
    
    @State private var isMicMuted = false
    @State private var isCameraOff = false
    
    public init(session: AgoraSessionManaging, remoteUid: Int?, onEndCall: @escaping () -> Void) {
        self.session = session
        self.remoteUid = remoteUid
        self.onEndCall = onEndCall
    }
    
    public var body: some View {
        VStack {
            // Main Stage: Remote User or Waiting State
            ZStack(alignment: .topTrailing) {
                if let uid = remoteUid {
                    AgoraVideoView(sessionManager: session, uid: uid)
                        .ignoresSafeArea()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(Text("Waiting for user to join...").foregroundColor(.white))
                }
                
                // Picture-in-Picture: Local User
                if !isCameraOff {
                    AgoraVideoView(sessionManager: session, uid: 0)
                        .frame(width: 120, height: 160)
                        .cornerRadius(12)
                        .padding()
                        .shadow(radius: 5)
                }
            }
            
            // Bottom Controls
            HStack(spacing: 40) {
                Button(action: {
                    isMicMuted.toggle()
                    session.muteLocalAudio(isMicMuted)
                }) {
                    CallControlButton(icon: isMicMuted ? "mic.slash.fill" : "mic.fill", 
                                      color: .white.opacity(0.2))
                }
                
                Button(action: onEndCall) {
                    CallControlButton(icon: "phone.down.fill", color: Color.App.destructive)
                }
                
                Button(action: {
                    isCameraOff.toggle()
                    session.enableLocalVideo(!isCameraOff)
                }) {
                    CallControlButton(icon: isCameraOff ? "video.slash.fill" : "video.fill", 
                                      color: .white.opacity(0.2))
                }
            }
            .padding(.bottom, 40)
            .padding(.top, 20)
        }
        .transition(.opacity)
    }
}

// Reusable Button Style
struct CallControlButton: View {
    var icon: String
    var color: Color
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 64, height: 64)
            .overlay(Image(systemName: icon).foregroundColor(.white).font(.title2))
    }
}
