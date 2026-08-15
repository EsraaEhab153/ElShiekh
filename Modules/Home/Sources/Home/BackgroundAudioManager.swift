import AVFoundation

class BackgroundAudioManager {
    static let shared = BackgroundAudioManager()
    
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var isPlaying = false

    private init() {
        setupAudioSession()
        setupAudioEngine()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }

    private func setupAudioEngine() {
        audioEngine.attach(playerNode)
        let format = audioEngine.outputNode.inputFormat(forBus: 0)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 44100) else { return }
        buffer.frameLength = 44100
        
        if let channelData = buffer.floatChannelData {
            for channel in 0..<Int(format.channelCount) {
                memset(channelData[channel], 0, Int(buffer.frameCapacity) * MemoryLayout<Float>.size)
            }
        }
        
        playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
    }

    func start() {
        guard !isPlaying else { return }
        do {
            try audioEngine.start()
            playerNode.play()
            isPlaying = true
            print("🔇 Silent Background Audio Started")
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }

    func stop() {
        playerNode.stop()
        audioEngine.stop()
        isPlaying = false
        print("🔇 Silent Background Audio Stopped")
    }
}
