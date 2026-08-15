//
//  ContentView.swift
//  ElShiekh
//
//  Created by Esraa Ehab on 01/08/2026.
//

import SwiftUI
import Authentication
import Home

struct ContentView: View {
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        Group {
            switch authManager.currentAuthState {
            case .bootstrapping:
                // App is checking Keychain / refreshing tokens — show a splash.
                ProgressView("Loading…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .authenticated(let user):
                // Authenticated → show HomeScreen.
                // The transition replaces the entire root view,
                // so there is no navigation stack to swipe back to login.
                HomeScreen()
                    .transition(.opacity)

            case .guest, .sessionExpired:
                // Not authenticated → show the auth flow.
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: authManager.currentAuthState)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager.shared)
}
