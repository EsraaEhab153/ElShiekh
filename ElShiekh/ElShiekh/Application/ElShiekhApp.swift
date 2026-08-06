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
            let validTestToken = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJtb2hhbWVkQHRlc3QuY29tIiwiaWF0IjoxNzg1OTY0MzcxLCJleHAiOjE3ODYwNTA3NzEsInJvbGVzIjpbIlJPTEVfU0hFSUtIIl0sInR5cGUiOiJhY2Nlc3MifQ.bEFKOh5bHZ1BB8-Z3_AtgonRegVNLmG63fqYwVyodm8lgBEQ6drOmitTt9jkJdmAQBF6z1mYkS1GjULcf5LxFQ"
            
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
