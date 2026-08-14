//
//  Notification+App.swift
//  Common
//
//  App-wide Notification.Name constants shared across modules.
//

import Foundation

public extension Notification.Name {
    /// Posted by AuthManager when the user session changes (login / logout).
    /// `object` carries the user-id `String` on login, or `nil` on logout.
    static let userSessionDidChange = Notification.Name("com.elshiekh.userSessionDidChange")

    /// Post this notification to request AuthManager to log the user out
    /// from any module without importing Authentication directly.
    static let appLogoutRequested = Notification.Name("com.elshiekh.appLogoutRequested")
}
