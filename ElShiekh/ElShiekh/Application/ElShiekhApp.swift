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
            let validTestToken = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhaG1lZEB0ZXN0LmNvbSIsImlhdCI6MTc4NjE5MzQ3MiwiZXhwIjoxNzg2Mjc5ODcyLCJyb2xlcyI6WyJST0xFX1NIRUlLSCJdLCJ0eXBlIjoiYWNjZXNzIn0.ofiYvT_q62H1TWFr-JKMHEaaXc9XMm5dgGIS9GFedEHTqibx6EslbRVHsGflkocEb080As_CROJzPSpfpcMyFg"
            
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
