//
//  RegisterViewModel.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation
import Combine

@MainActor
public final class RegisterViewModel: ObservableObject {

    // MARK: - Form state

    @Published public var username = ""
    @Published public var firstName = ""
    @Published public var lastName = ""
    @Published public var email = ""
    @Published public var password = ""
    @Published public var confirmPassword = ""
    @Published public var phoneNumber = ""
    @Published public var gender = ""

    public let genderOptions = ["Male", "Female"]

    // MARK: - Error state
    
    @Published public var firstNameError: String?
    @Published public var lastNameError: String?
    @Published public var usernameError: String?
    @Published public var emailError: String?
    @Published public var passwordError: String?
    @Published public var confirmPasswordError: String?
    @Published public var phoneNumberError: String?
    @Published public var genderError: String?

    // MARK: - UI state

    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var registrationSuccessful = false

    // MARK: - Dependencies

    private let authManager: AuthManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    public init(authManager: AuthManager = .shared) {
        self.authManager = authManager

        authManager.$isLoading
            .assign(to: &$isLoading)

        authManager.$errorMessage
            .assign(to: &$errorMessage)
    }

    // MARK: - Actions

    public func register() {
        guard validate() else { return }
        authManager.register(
            username: username,
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            phoneNumber: phoneNumber
        ) { [weak self] in
            self?.registrationSuccessful = true
        }
    }

    public func clearError() {
        errorMessage = nil
        firstNameError = nil
        lastNameError = nil
        usernameError = nil
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
        phoneNumberError = nil
        genderError = nil
    }

    // MARK: - Private

    private func validate() -> Bool {
        firstNameError = nil
        lastNameError = nil
        usernameError = nil
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
        phoneNumberError = nil
        genderError = nil

        var isValid = true

        if firstName.isEmpty { firstNameError = "Required"; isValid = false }
        if lastName.isEmpty { lastNameError = "Required"; isValid = false }
        if username.isEmpty { usernameError = "Required"; isValid = false }
        if email.isEmpty { emailError = "Required"; isValid = false }
        if gender.isEmpty { genderError = "Required"; isValid = false }
        
        if password.isEmpty { 
            passwordError = "Required"
            isValid = false 
        }
        
        if confirmPassword.isEmpty {
            confirmPasswordError = "Required"
            isValid = false
        } else if password != confirmPassword {
            confirmPasswordError = "Passwords do not match."
            isValid = false
        }
        
        if phoneNumber.isEmpty {
            phoneNumberError = "Required"
            isValid = false
        } else {
            let phoneRegex = #"^01[0125]\d{8}$"#
            let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            if !phonePredicate.evaluate(with: phoneNumber) {
                phoneNumberError = "Enter a valid Egyptian phone number (e.g. 01012345678)."
                isValid = false
            }
        }
        
        if !isValid && errorMessage == nil {
            errorMessage = "Please fix the errors above."
        }

        return isValid
    }
}
