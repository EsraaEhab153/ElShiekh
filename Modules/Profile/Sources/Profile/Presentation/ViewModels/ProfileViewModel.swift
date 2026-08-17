import Foundation
import Combine

public class ProfileViewModel: ObservableObject {
    @Published public var profile: ProfileModel
    
    public init(profile: ProfileModel = ProfileModel(username: "yassenRamadan1", email: "yassen.hassan@gmail.com")) {
        self.profile = profile
    }
    
    public func logout() {
        // Implement logout logic here
        print("Logout tapped")
    }
}
