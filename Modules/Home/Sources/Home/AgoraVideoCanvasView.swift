import SwiftUI
import AgoraRtcKit

public struct AgoraVideoCanvasView: UIViewRepresentable {
    public var uid: UInt
    public var renderMode: AgoraVideoRenderMode = .hidden
    public var setupCanvas: (AgoraRtcVideoCanvas) -> Void

    public init(uid: UInt, renderMode: AgoraVideoRenderMode = .hidden, setupCanvas: @escaping (AgoraRtcVideoCanvas) -> Void) {
        self.uid = uid
        self.renderMode = renderMode
        self.setupCanvas = setupCanvas
    }

    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        let canvas = AgoraRtcVideoCanvas()
        canvas.view = view
        canvas.renderMode = renderMode
        canvas.uid = uid
        setupCanvas(canvas)
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {}
}
