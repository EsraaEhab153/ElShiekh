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
            let validTestToken = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhaG1lZEB0ZXN0LmNvbSIsImlhdCI6MTc4NjEwNjgwOCwiZXhwIjoxNzg2MTkzMjA4LCJyb2xlcyI6WyJST0xFX1NIRUlLSCJdLCJ0eXBlIjoiYWNjZXNzIn0.OMW9H_npdyHozChd00ep0tHouihVKaLNudVeu4WgshwQDv1lkC5r_VCVFETIfCAoIPdg27rCYJfhRz1DEohbFA"
            
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
