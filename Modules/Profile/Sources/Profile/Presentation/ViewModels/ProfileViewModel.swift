import Foundation
import Combine
import Authentication

@MainActor
public class ProfileViewModel: ObservableObject {
    @Published public var profile: ProfileModel
    @Published public var isLoggingOut = false
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(profile: ProfileModel = ProfileModel(username: "yassenRamadan1", email: "yassen.hassan@gmail.com")) {
        self.profile = profile
        
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
