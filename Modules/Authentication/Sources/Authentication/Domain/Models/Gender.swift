//
//  Gender.swift
//  Authentication
//
//  Created by Esraa Ehab on 15/08/2026.
//
import Foundation

public enum Gender: String, Codable, CaseIterable {
    case male = "MALE"
    case female = "FEMALE"
    
    public var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}
