//
//  AuthViewModel.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = "demo@example.com"
    @Published var password: String = "demo_password_abc123"
    @Published private(set) var accessTokenValue: String = "Not stored"
    @Published private(set) var refreshTokenValue: String = "Not stored"
    @Published private(set) var userPasswordValue: String = "Not stored"
    @Published private(set) var statusMessage: String = "No credentials saved yet."
    @Published private(set) var isLoading: Bool = false

    private let secureStore: SecureStoreServiceProtocol
    private let authWebService: AuthWebServiceProtocol

    init(
        secureStore: SecureStoreServiceProtocol,
        authWebService: AuthWebServiceProtocol
    ) {
        self.secureStore = secureStore
        self.authWebService = authWebService
        loadStoredCredentials()
    }

    convenience init() {
        self.init(
            secureStore: SecureStoreService(),
            authWebService: AuthWebService()
        )
    }

    func login() async -> Bool {
        isLoading = true
        defer { isLoading = false }

        let request: LoginRequest = LoginRequest(
            email: email,
            password: password
        )

        do {
            let response: LoginResponse = try await authWebService.login(request: request)
            let credentials: AuthCredentials = AuthCredentials(
                loginResponse: response,
                userPassword: request.password
            )

            try secureStore.saveCredentials(credentials)

            loadStoredCredentials()
            statusMessage = "Decoded LoginResponse from WebService and saved credentials into secure storage."
            return true
        } catch {
            statusMessage = error.localizedDescription
            return false
        }
    }

    func loadStoredCredentials() {
        do {
            let credentials: AuthCredentials? = try secureStore.loadCredentials()

            accessTokenValue = displayValue(for: credentials?.accessToken)
            refreshTokenValue = displayValue(for: credentials?.refreshToken)
            userPasswordValue = displayValue(for: credentials?.userPassword)
            statusMessage = "Loaded credential values from secure storage."
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    func clearCredentials() {
        do {
            try secureStore.clearCredentials()

            accessTokenValue = "Not stored"
            refreshTokenValue = "Not stored"
            userPasswordValue = "Not stored"
            statusMessage = "Removed all credentials from secure storage."
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func displayValue(for value: String?) -> String {
        guard let value: String = value, value.isEmpty == false else {
            return "Not stored"
        }
        return value
    }
}
