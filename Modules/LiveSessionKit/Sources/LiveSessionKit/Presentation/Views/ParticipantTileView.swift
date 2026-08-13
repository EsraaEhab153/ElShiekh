//
//  ParticipantTileView.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import SwiftUI
import Common
import UIKit
import Combine
import AgoraKit


public struct LiveSessionVideoView: UIViewRepresentable {
    let repository: LiveSessionRepositoryProtocol
    let uid: Int?

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
        let localRepo = self.repository

        context.coordinator.cancellable = repository.connectionStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak view] state in
                guard let view = view else { return }
                if let uid = localUid, uid != 0 {
                    _ = localRepo.setupRemoteVideoCanvas(view, forUid: uid)
                } else {
                    _ = localRepo.setupLocalVideoCanvas(view)
                }
            }

        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        bindCanvas(to: uiView)
    }

    private func bindCanvas(to view: UIView) {
        if let uid = uid, uid != 0 {
            _ = repository.setupRemoteVideoCanvas(view, forUid: uid)
        } else {
            _ = repository.setupLocalVideoCanvas(view)
        }
    }
}

public struct ParticipantTileView: View {
    @Environment(\.dsColors) private var dsColors
    public let participant: SessionParticipant
    public let repository: LiveSessionRepositoryProtocol?

    public init(participant: SessionParticipant, repository: LiveSessionRepositoryProtocol? = nil) {
        self.participant = participant
        self.repository = repository
    }

    public var body: some View {
        VStack(spacing: DSSpacing.sm) {
            ZStack {
                if participant.isVideoEnabled, let repository = repository {
                    LiveSessionVideoView(repository: repository, uid: participant.uid)
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(dsColors.primaryContainer)
                        .frame(width: 64, height: 64)

                    Text(initials(from: participant.name))
                        .dsFont(DSTypography.headlineMedium)
                        .foregroundColor(dsColors.primary)
                }

                if participant.isMuted {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "mic.slash.fill")
                                .font(.system(size: 12))
                                .padding(4)
                                .background(dsColors.error)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                    .frame(width: 64, height: 64)
                }
            }

            HStack(spacing: DSSpacing.xxs) {
                Text(participant.name ?? "User \(participant.uid)")
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textPrimary)
                    .lineLimit(1)

                if participant.isHost {
                    Text("(Host)")
                        .dsFont(DSTypography.labelSmall)
                        .foregroundColor(dsColors.primary)
                }
            }

            if !participant.isFullyConnected {
                Text("Connecting...")
                    .dsFont(DSTypography.labelSmall)
                    .foregroundColor(dsColors.warning)
            } else if participant.audioLevel > 0 {
                ProgressView(value: Double(min(participant.audioLevel, 100)), total: 100.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: dsColors.primary))
                    .frame(width: 60)
            }
        }
        .padding(DSSpacing.md)
        .background(dsColors.surfaceContainerLow)
        .cornerRadius(DSRadius.lg)
    }

    private func initials(from name: String?) -> String {
        guard let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "U"
        }
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}
