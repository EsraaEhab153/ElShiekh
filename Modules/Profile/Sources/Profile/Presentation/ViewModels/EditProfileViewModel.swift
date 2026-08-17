import Foundation
import Combine
import NetworkKit

@MainActor
public class EditProfileViewModel: ObservableObject {
    @Published public var firstName: String = ""
    @Published public var lastName: String = ""
    @Published public var phoneNumber: String = ""
    
    @Published public var isSaving: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var isSuccess: Bool = false
    
    private let repository: ProfileRepositoryProtocol
    private let sheikhId: String // Retrieved from current session
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        sheikhId: String,
        initialFirstName: String = "",
        initialLastName: String = "",
        initialPhoneNumber: String = "",
        repository: ProfileRepositoryProtocol = ProfileRepositoryImpl()
    ) {
        self.sheikhId = sheikhId
        self.firstName = initialFirstName
        self.lastName = initialLastName
        self.phoneNumber = initialPhoneNumber
        self.repository = repository
    }
    
    public func saveProfile() {
        isSaving = true
        errorMessage = nil
        isSuccess = false
        
        repository.updateProfile(id: sheikhId, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isSaving = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] responseData in
                guard let self = self else { return }
                self.isSaving = false
                self.isSuccess = true
                // Optionally update global session/auth state here with responseData
            }
            .store(in: &cancellables)
    }
}
