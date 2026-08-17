import Foundation
import Combine
import NetworkKit

public protocol ProfileRepositoryProtocol {
    func updateProfile(id: String, firstName: String, lastName: String, phoneNumber: String) -> AnyPublisher<UpdatedProfileData, NetworkError>
}

public final class ProfileRepositoryImpl: ProfileRepositoryProtocol {
    private let networkService: any NetworkServiceProtocol
    
    public init(networkService: any NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    public func updateProfile(id: String, firstName: String, lastName: String, phoneNumber: String) -> AnyPublisher<UpdatedProfileData, NetworkError> {
        networkService.request(ProfileEndpoints.updateProfile(id: id, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber))
    }
}

public struct UpdatedProfileData: Codable {
    public let id: String
    public let username: String
    public let firstName: String
    public let lastName: String
    public let phoneNumber: String
    public let profilePictureUrl: String?
}
