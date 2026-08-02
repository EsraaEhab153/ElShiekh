import SwiftUI
import Common

public struct ConnectingView: View {
    public init() {}
    
    public var body: some View {
        Text("...Connecting")
            .font(.system(size: 24, weight: .semibold))
            .foregroundColor(.white)
    }
}

public struct ActiveCallView: View {
    @ObservedObject var agoraManager: AgoraManager
    var onEndCall: () -> Void
    
    public init(agoraManager: AgoraManager, onEndCall: @escaping () -> Void) {
        self.agoraManager = agoraManager
        self.onEndCall = onEndCall
    }
    
    public var body: some View {
        VStack {
            // Main Stage: Remote User or Waiting State
            ZStack(alignment: .topTrailing) {
                if let remoteUid = agoraManager.remoteUserId {
                    AgoraVideoCanvasView(uid: remoteUid, renderMode: .hidden) { canvas in
                        agoraManager.setupRemoteVideo(to: canvas)
                    }
                    .ignoresSafeArea()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(Text("Waiting for user to join...").foregroundColor(.white))
                }
                
                // Picture-in-Picture: Local User
                if !agoraManager.isCameraOff {
                    AgoraVideoCanvasView(uid: 0, renderMode: .hidden) { canvas in
                        agoraManager.setupLocalVideo(to: canvas)
                    }
                    .frame(width: 120, height: 160)
                    .cornerRadius(12)
                    .padding()
                    .shadow(radius: 5)
                }
            }
            
            // Bottom Controls
            HStack(spacing: 40) {
                Button(action: { agoraManager.toggleMic() }) {
                    CallControlButton(icon: agoraManager.isMicMuted ? "mic.slash.fill" : "mic.fill", 
                                      color: .white.opacity(0.2))
                }
                
                Button(action: onEndCall) {
                    CallControlButton(icon: "phone.down.fill", color: Color.App.destructive)
                }
                
                Button(action: { agoraManager.toggleCamera() }) {
                    CallControlButton(icon: agoraManager.isCameraOff ? "video.slash.fill" : "video.fill", 
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
