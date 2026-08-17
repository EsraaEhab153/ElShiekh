import Foundation

public struct ProfileModel {
    public let username: String
    public let email: String
    
    public init(username: String, email: String) {
        self.username = username
        self.email = email
    }
    
    public var firstLetter: String {
        return String(username.prefix(1)).uppercased()
    }
}
