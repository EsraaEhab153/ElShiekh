//
//  RealtimeClient.swift
//  RealtimeKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import Combine
import Foundation

public final class RealtimeClient: ObservableObject, RealtimeConnecting,
    RealtimeTransportDelegate, @unchecked Sendable
{
    private let transport: RealtimeTransportProtocol
    private let registry: RealtimeSubscriptionRegistry

    private let stateSubject = CurrentValueSubject<
        RealtimeConnectionState, Never
    >(.disconnected)
    private let didReconnectSubject = PassthroughSubject<Void, Never>()

    public var connectionStatePublisher:
        AnyPublisher<RealtimeConnectionState, Never>
    {
        stateSubject.eraseToAnyPublisher()
    }

    public var currentState: RealtimeConnectionState {
        stateSubject.value
    }

    public var didReconnectPublisher: AnyPublisher<Void, Never> {
        didReconnectSubject.eraseToAnyPublisher()
    }

    init(
        transport: RealtimeTransportProtocol = SwiftStompTransport(),
        registry: RealtimeSubscriptionRegistry = RealtimeSubscriptionRegistry()
    ) {
        self.transport = transport
        self.registry = registry
        self.transport.delegate = self
    }

    public convenience init() {
        self.init(
            transport: SwiftStompTransport(),
            registry: RealtimeSubscriptionRegistry()
        )
    }

    public func connect(url: URL, authToken: String) async throws {
        print("🟢 [RealtimeClient] connect() called — url=\(url), tokenEmpty=\(authToken.isEmpty)")
        guard !authToken.isEmpty else {
            let error = RealtimeError.authenticationRejected
            print("🟢 [RealtimeClient] ❌ Empty auth token — sending .failed(.authenticationRejected)")
            stateSubject.send(.failed(error))
            throw error
        }

        stateSubject.send(.connecting)
        transport.autoReconnect = true

        let headers: [String: String] = [
            "Authorization": "Bearer \(authToken)",
            "passcode": authToken,
        ]

        print("🟢 [RealtimeClient] Initiating transport.connect()...")
        transport.connect(url: url, headers: headers)
        transport.enableAutoPing(interval: 10)
        print("🟢 [RealtimeClient] connect() returned (handshake is async)")
    }

    public func disconnect() async {
        print("🔴 [RealtimeClient] disconnect() called")
        transport.disconnect()
        registry.clear()
        stateSubject.send(.disconnected)
        print("🔴 [RealtimeClient] disconnect() completed — registry cleared, state=.disconnected")
    }

    public func subscribe(topic: String) -> AnyPublisher<
        RealtimeEventEnvelope, Never
    > {
        let (publisher, _) = registry.register(topic: topic)
        if currentState == .connected {
            transport.subscribe(to: topic)
        }
        return publisher
    }

    public func stream(for topic: String) -> AsyncStream<RealtimeEventEnvelope>
    {
        let (_, stream) = registry.register(topic: topic)
        if currentState == .connected {
            transport.subscribe(to: topic)
        }
        return stream
    }

    public func unsubscribe(topic: String) {
        registry.unregister(topic: topic)
        if currentState == .connected {
            transport.unsubscribe(from: topic)
        }
    }

    // MARK: - RealtimeTransportDelegate

    func transportDidConnect(isReconnect: Bool) {
        print("🟢 [RealtimeClient] transportDidConnect (isReconnect=\(isReconnect))")
        let activeTopics = registry.activeTopics()
        print("🟢 [RealtimeClient] Re-subscribing to \(activeTopics.count) topic(s): \(activeTopics)")
        for topic in activeTopics {
            transport.subscribe(to: topic)
        }

        if isReconnect {
            didReconnectSubject.send(())
        }

        stateSubject.send(.connected)
        print("🟢 [RealtimeClient] State → .connected")
    }

    func transportDidDisconnect(wasClean: Bool) {
        print("🔴 [RealtimeClient] transportDidDisconnect (wasClean=\(wasClean))")
        if wasClean {
            stateSubject.send(.disconnected)
            print("🔴 [RealtimeClient] State → .disconnected")
        } else {
            stateSubject.send(.reconnecting(attempt: 1))
            print("🔴 [RealtimeClient] State → .reconnecting(attempt: 1)")
        }
    }

    func transportDidReceiveMessage(
        destination: String,
        body: Any?,
        headers: [String: String]
    ) {
        print("📩 [RealtimeClient] didReceiveMessage — destination=\(destination)")
        do {
            let envelope = try RealtimeFrameDecoder.decode(
                body: body,
                headers: headers
            )
            registry.publish(envelope: envelope, to: destination)
            print("📩 [RealtimeClient] ✅ Published envelope (eventType=\(envelope.eventType)) to destination")
        } catch {
            print("📩 [RealtimeClient] ❌ Failed to decode message: \(error)")
            stateSubject.send(.failed(.malformedEnvelope))
        }
    }

    func transportDidEncounterError(description: String, isAuthError: Bool) {
        print("❌ [RealtimeClient] transportError — \(description), isAuth=\(isAuthError)")
        if isAuthError {
            stateSubject.send(.failed(.authenticationRejected))
            print("❌ [RealtimeClient] State → .failed(.authenticationRejected)")
        } else {
            stateSubject.send(
                .failed(.transportError(description: description))
            )
            print("❌ [RealtimeClient] State → .failed(.transportError)")
        }
    }
}
