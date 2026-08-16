import Foundation
import ActivityKit

public struct CallAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var status: String
        
        public init(status: String) {
            self.status = status
        }
    }

    public var callerName: String
    public var requestId: String
    
    public init(callerName: String, requestId: String) {
        self.callerName = callerName
        self.requestId = requestId
    }
}
