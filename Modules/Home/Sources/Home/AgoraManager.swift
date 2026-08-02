import Foundation
import AgoraRtcKit

public class AgoraManager: NSObject, ObservableObject {
    @Published public var remoteUserId: UInt? = nil
    @Published public var isMicMuted: Bool = false
    @Published public var isCameraOff: Bool = false
    
    private var agoraEngine: AgoraRtcEngineKit!
    private let appId = "YOUR_AGORA_APP_ID" // Needs to be replaced with a real App ID
    
    public override init() {
        super.init()
    }
    
    public func initializeAndJoin(channel: String, token: String?) {
        let config = AgoraRtcEngineConfig()
        config.appId = appId
        
        agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        
        agoraEngine.enableVideo()
        agoraEngine.startPreview()
        
        let option = AgoraRtcChannelMediaOptions()
        option.clientRoleType = .broadcaster
        option.channelProfile = .communication // Best for 1-to-1 meetings
        
        agoraEngine.joinChannel(byToken: token, channelId: channel, uid: 0, mediaOptions: option)
    }
    
    public func leaveChannel() {
        agoraEngine.stopPreview()
        agoraEngine.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
    }
    
    public func setupLocalVideo(to canvas: AgoraRtcVideoCanvas) {
        agoraEngine.setupLocalVideo(canvas)
    }
    
    public func setupRemoteVideo(to canvas: AgoraRtcVideoCanvas) {
        agoraEngine.setupRemoteVideo(canvas)
    }
    
    public func toggleMic() {
        isMicMuted.toggle()
        agoraEngine.muteLocalAudioStream(isMicMuted)
    }
    
    public func toggleCamera() {
        isCameraOff.toggle()
        agoraEngine.muteLocalVideoStream(isCameraOff)
    }
}

// MARK: - AgoraRtcEngineDelegate
extension AgoraManager: AgoraRtcEngineDelegate {
    public func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        DispatchQueue.main.async {
            self.remoteUserId = uid
        }
    }
    
    public func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        DispatchQueue.main.async {
            if self.remoteUserId == uid {
                self.remoteUserId = nil
            }
        }
    }
}
