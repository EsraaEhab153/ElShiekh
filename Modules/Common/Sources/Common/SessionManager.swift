//
//  SessionManager.swift
//  Common
//
//  Lightweight in-memory + UserDefaults session cache.
//  Populated by AuthManager on login / silentLogin; read by feature modules
//  (e.g. HomeViewModel) to obtain the current user's ID.
//

import Foundation

// MARK: - SessionUser

public struct SessionUser: Codable, Sendable, Equatable {
    public let id: String
    public let username: String
    public let email: String
    public let fullName: String
    public let profilePictureUrl: String?
    public let createdAt: Date?

    public init(
        id: String,
        username: String,
        email: String,
        fullName: String,
        profilePictureUrl: String? = nil,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.fullName = fullName
        self.profilePictureUrl = profilePictureUrl
        self.createdAt = createdAt
    }
}

// MARK: - SessionManager

public final class SessionManager: @unchecked Sendable {

    public static let shared = SessionManager()

    private let defaults = UserDefaults.standard
    private static let storageKey = "SessionManager.currentUser"
    private let lock = NSLock()

    private var _currentUser: SessionUser?

    /// The currently authenticated user, or `nil` if logged out.
    public var currentUser: SessionUser? {
        lock.lock()
        defer { lock.unlock() }
        return _currentUser
    }

    private init() {
        // Restore from UserDefaults on launch.
        if let data = defaults.data(forKey: Self.storageKey),
           let user = try? JSONDecoder().decode(SessionUser.self, from: data) {
            _currentUser = user
        }
    }

    /// Persist the authenticated user to memory + disk.
    public func save(user: SessionUser) {
        lock.lock()
        _currentUser = user
        lock.unlock()
        if let data = try? JSONEncoder().encode(user) {
            defaults.set(data, forKey: Self.storageKey)
        }
    }

    /// Clear the session (logout).
    public func clear() {
        lock.lock()
        _currentUser = nil
        lock.unlock()
        defaults.removeObject(forKey: Self.storageKey)
    }
}
