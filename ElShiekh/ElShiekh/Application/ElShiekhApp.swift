//
//  ElShiekhApp.swift
//  ElShiekh
//
//  Created by Esraa Ehab on 01/08/2026.
//

import SwiftUI
import Authentication

@main
struct ElShiekhApp: App {
    @StateObject private var authManager = AuthManager.shared

    init() {
        // Wire up the network interceptor to use Keychain tokens
        // and AuthManager's refresh logic (replaces the hardcoded test token).
        AuthManager.configureInterceptor()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .task {
                    // Attempt silent login: checks Keychain for existing tokens,
                    // validates them against /auth/me, and sets authState accordingly.
                    authManager.silentLoginOnLaunch()
                }
        }
    }
}
