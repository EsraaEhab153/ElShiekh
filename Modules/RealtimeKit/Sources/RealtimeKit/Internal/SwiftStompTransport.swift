//
//  SwiftStompTransport.swift
//  RealtimeKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import Foundation
import SwiftStomp

protocol RealtimeTransportDelegate: AnyObject {
    func transportDidConnect(isReconnect: Bool)
    func transportDidDisconnect(wasClean: Bool)
    func transportDidReceiveMessage(destination: String, body: Any?, headers: [String: String])
    func transportDidEncounterError(description: String, isAuthError: Bool)
}

protocol RealtimeTransportProtocol: AnyObject {
    var delegate: RealtimeTransportDelegate? { get set }
    var autoReconnect: Bool { get set }

    func connect(url: URL, headers: [String: String]?)
    func disconnect()
    func enableAutoPing(interval: TimeInterval)
    func subscribe(to topic: String)
    func unsubscribe(from topic: String)
}

final class SwiftStompTransport: NSObject, RealtimeTransportProtocol, SwiftStompDelegate {
    weak var delegate: RealtimeTransportDelegate?

    private var stomp: SwiftStomp?
    private var isConnectedBefore = false

    var autoReconnect: Bool = true {
        didSet {
            stomp?.autoReconnect = autoReconnect
        }
    }

    override init() {
        super.init()
    }

    func connect(url: URL, headers: [String: String]?) {
        print("🔌 [STOMP] connect() — url=\(url)")
        // Pass the headers to BOTH the STOMP frame and the initial HTTP WebSocket upgrade request
        let client = SwiftStomp(host: url, headers: headers, httpConnectionHeaders: headers)
        client.delegate = self
        client.autoReconnect = autoReconnect
        self.stomp = client

        client.connect()
        print("🔌 [STOMP] client.connect() called (async handshake)")
    }

    func disconnect() {
        print("🔌 [STOMP] disconnect() called")
        stomp?.disconnect()
        stomp = nil
        isConnectedBefore = false
        print("🔌 [STOMP] disconnect() completed — stomp=nil")
    }

    func enableAutoPing(interval: TimeInterval) {
        stomp?.enableAutoPing(pingInterval: interval)
    }

    func subscribe(to topic: String) {
        stomp?.subscribe(to: topic)
    }

    func unsubscribe(from topic: String) {
        stomp?.unsubscribe(from: topic)
    }

    // MARK: - SwiftStompDelegate

    func onConnect(swiftStomp: SwiftStomp, connectType: StompConnectType) {
        print("🟢 [STOMP] onConnect — connectType=\(connectType), isConnectedBefore=\(isConnectedBefore)")
        let isReconnect = isConnectedBefore || (connectType == .toSocketEndpoint)
        isConnectedBefore = true
        delegate?.transportDidConnect(isReconnect: isReconnect)
    }

    func onDisconnect(swiftStomp: SwiftStomp, disconnectType: StompDisconnectType) {
        print("🔴 [STOMP] onDisconnect — disconnectType=\(disconnectType)")
        // FIX: .fromStomp is an intentional STOMP-level disconnect (clean).
        // .fromSocket is an unexpected socket-level drop (unclean → triggers reconnect).
        let wasClean: Bool
        switch disconnectType {
        case .fromStomp:
            wasClean = true
        case .fromSocket:
            wasClean = false
        @unknown default:
            wasClean = false
        }
        print("🔴 [STOMP] wasClean=\(wasClean)")
        delegate?.transportDidDisconnect(wasClean: wasClean)
    }

    func onMessageReceived(swiftStomp: SwiftStomp, message: Any?, messageId: String, destination: String, headers: [String: String]) {
        print("📩 [STOMP] onMessageReceived — destination=\(destination), messageId=\(messageId)")
        delegate?.transportDidReceiveMessage(destination: destination, body: message, headers: headers)
    }

    func onError(swiftStomp: SwiftStomp, briefDescription: String, fullDescription: String?, receiptId: String?, type: StompErrorType) {
        print("❌ [STOMP] onError — brief=\(briefDescription), full=\(fullDescription ?? "nil"), type=\(type)")
        let isAuthError = briefDescription.lowercased().contains("401") ||
            briefDescription.lowercased().contains("unauthorized") ||
            (fullDescription?.lowercased().contains("unauthorized") ?? false)
        print("❌ [STOMP] isAuthError=\(isAuthError)")
        delegate?.transportDidEncounterError(description: fullDescription ?? briefDescription, isAuthError: isAuthError)
    }

    func onReceipt(swiftStomp: SwiftStomp, receiptId: String) {
        // Receipt callback if needed
    }
}
