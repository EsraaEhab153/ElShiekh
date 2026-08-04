//
//  File.swift
//  
//
//  Created by Esraa Ehab on 03/08/2026.
//

import Foundation

public enum ProviderAvailabilityStatus: String, Codable {
    case available = "AVAILABLE"
    case busy = "BUSY"
    case offline = "OFFLINE"
}

public struct AcceptResponse: Codable, Sendable {
    public let agoraToken: String
    public let channelName: String
}

public struct SheikhMeetingRequestEvent: Codable, Sendable {
    public let requestId: String
    public let studentId: Int?
    public let studentName: String?
    public let avatarUrl: String?
}
