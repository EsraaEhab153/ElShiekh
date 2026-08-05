//
//  ElShiekhApp.swift
//  ElShiekh
//
//  Created by Esraa Ehab on 01/08/2026.
//

import SwiftUI
import NetworkKit

@main
struct ElShiekhApp: App {
    init() {
            let validTestToken = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJzaGVpa2hAdGVzdC5jb20iLCJpYXQiOjE3ODU4NTM3NTYsImV4cCI6MTc4NTk0MDE1Niwicm9sZXMiOlsiUk9MRV9TSEVJS0giXSwidHlwZSI6ImFjY2VzcyJ9.0X0Byu8qzK2IMPjZrqOBbFPzvEnlHS3jFL_j3SK6uOlVPFMp-zejd3XVuhwWIJJis7R9jLni0AiFX25Hy1pi3Q"
            
            AppRequestInterceptors.shared.tokenProvider = {
                return validTestToken
            }
            
            AppRequestInterceptors.shared.onRefreshNeeded = { completion in
                completion(false)
            }
        }
        
        var body: some Scene {
            WindowGroup {
                ContentView()
            }
        }
}
