//
//  File.swift
//  
//
//  Created by Esraa Ehab on 03/08/2026.
//

import Foundation
import Alamofire

public enum InstantMeetingEndpoints: APIEndpoint {
    case updateAvailability(status: ProviderAvailabilityStatus)
    case getPendingRequests
    case acceptRequest(requestId: String)
    case declineRequest(requestId: String)
    case endMeeting(requestId: String)
    
    public var baseURL: BaseURLType {
        return .main
    }
    
    public var path: String {
        switch self {
        case .updateAvailability:
            return "instant-meetings/sheikh/availability"
        case .getPendingRequests:
            return "instant-meetings/sheikh/pending"
        case .acceptRequest(let id):
            return "instant-meetings/\(id)/accept"
        case .declineRequest(let id):
            return "instant-meetings/\(id)/decline"
        case .endMeeting(let id):
            return "instant-meetings/\(id)/end"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .updateAvailability: return .put
        case .getPendingRequests: return .get
        case .acceptRequest, .declineRequest, .endMeeting: return .post
        }
    }
    
    public var parameters: Parameters? {
        switch self {
        case .updateAvailability(let status):
            // Assuming the backend expects {"status": "AVAILABLE"} in the body
            return ["status": status.rawValue]
        default:
            return nil
        }
    }
    
    public var encoding: ParameterEncoding {
        switch self {
        case .updateAvailability:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
}
