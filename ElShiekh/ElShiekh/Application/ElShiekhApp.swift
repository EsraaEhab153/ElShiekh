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
            let validTestToken = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhaG1lZEB0ZXN0LmNvbSIsImlhdCI6MTc4NjU1ODk0OCwiZXhwIjoxNzg2NjQ1MzQ4LCJyb2xlcyI6WyJST0xFX1NIRUlLSCJdLCJ0eXBlIjoiYWNjZXNzIn0.5uTqwh6SjAFfQEMqcqRpGVcDOU76HrGAjGQk5gB-6qzt0tq-1pupX4BVhNfcg4Xfgkhxfidw6FbV9HMmTKe94w"
            
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
