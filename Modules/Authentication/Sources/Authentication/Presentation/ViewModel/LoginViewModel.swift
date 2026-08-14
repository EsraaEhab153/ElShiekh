import Combine
//
//  LoginViewModel.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation

@MainActor
public final class LoginViewModel: ObservableObject {

    // MARK: - Form state

    @Published public var email = ""
    @Published public var password = ""

    // MARK: - Error state
    
    @Published public var emailError: String?
    @Published public var passwordError: String?

    // MARK: - UI state (mirrored from AuthManager)

    @Published public var isLoading = false
    @Published public var errorMessage: String?

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

    public func login() {
        emailError = nil
        passwordError = nil
        
        var isValid = true
        
        if email.isEmpty {
            emailError = "Please enter your email"
            isValid = false
        }
        
        if password.isEmpty {
            passwordError = "Please enter your password"
            isValid = false
        }
        
        guard isValid else { return }
        
        authManager.login(email: email, password: password)
    }

    public func clearError() {
        errorMessage = nil
        emailError = nil
        passwordError = nil
    }
}
