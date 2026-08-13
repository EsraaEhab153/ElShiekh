//
//  AgoraVideoView.swift
//  AgoraKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import SwiftUI
import UIKit
import Combine

public struct AgoraVideoView: UIViewRepresentable {

    private let sessionManager: AgoraSessionManaging
    private let uid: Int?

    public init(sessionManager: AgoraSessionManaging, uid: Int? = nil) {
        self.sessionManager = sessionManager
        self.uid = uid
    }

    public class Coordinator {
        var cancellable: AnyCancellable?
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        bindCanvas(to: view)

        let localUid = self.uid
        let localManager = self.sessionManager

        context.coordinator.cancellable = sessionManager.connectionStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak view] state in 
                guard let view = view else { return }
                if let uid = localUid, uid != 0 {
                    _ = localManager.setupRemoteVideoCanvas(view, forUid: uid)
                } else {
                    _ = localManager.setupLocalVideoCanvas(view)
                }
            }

        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        bindCanvas(to: uiView)
    }

    private func bindCanvas(to view: UIView) {
        if let uid = uid, uid != 0 {
            _ = sessionManager.setupRemoteVideoCanvas(view, forUid: uid)
        } else {
            _ = sessionManager.setupLocalVideoCanvas(view)
        }
    }
}
