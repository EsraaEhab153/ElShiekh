import Foundation
import Combine
import Common
import Authentication

@MainActor
public class ProfileViewModel: ObservableObject {
    @Published public var profile: ProfileModel
    @Published public var isLoggingOut = false
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        if let currentUser = SessionManager.shared.currentUser {
            self.profile = ProfileModel(username: currentUser.username, email: currentUser.email)
        } else {
            self.profile = ProfileModel(username: "Guest", email: "guest@example.com")
        }
        
        // Optional: observe AuthManager's loading state if needed.
        // The app router automatically dismisses this screen when authState changes.
    }
    
    public func logout() {
        isLoggingOut = true
        // AuthManager handles fetching the refreshToken, making the /api/auth/logout POST call,
        // clearing the tokens and user defaults, and resetting the auth state to .guest.
        AuthManager.shared.logout()
    }
}
