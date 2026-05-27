//
//  AuthViewModelTests.swift
//  MyStorageTests
//
//  Created by Punyawat on 25/5/2569 BE.
//

import XCTest
@testable import MyStorage

@MainActor
final class AuthViewModelTests: XCTestCase {
    
    func testInitLoadsStoredCredentialsIntoPublishedValues() {
        let secureStore: MockSecureStoreService = MockSecureStoreService()
        secureStore.storedCredentials = AuthCredentials(
            accessToken: "stored-access-token",
            refreshToken: "stored-refresh-token",
            userPassword: "stored-password"
        )
        let authWebService: MockAuthWebService = MockAuthWebService()

        let viewModel: AuthViewModel = AuthViewModel(
            secureStore: secureStore,
            authWebService: authWebService
        )

        XCTAssertEqual(viewModel.accessTokenValue, "stored-access-token")
        XCTAssertEqual(viewModel.refreshTokenValue, "stored-refresh-token")
        XCTAssertEqual(viewModel.userPasswordValue, "stored-password")
        XCTAssertEqual(viewModel.statusMessage, "Loaded credential values from secure storage.")
    }

    func testLoginSuccessSavesCredentialsAndUpdatesDisplayedValues() async {
        let secureStore: MockSecureStoreService = MockSecureStoreService()
        let authWebService: MockAuthWebService = MockAuthWebService()
        authWebService.result = .success(
            LoginResponse(
                accessToken: "response-access-token",
                refreshToken: "response-refresh-token",
                tokenType: "Bearer",
                expiresIn: 3600
            )
        )
        let viewModel: AuthViewModel = AuthViewModel(
            secureStore: secureStore,
            authWebService: authWebService
        )
        viewModel.email = "demo@example.com"
        viewModel.password = "password-123"

        let didLogin: Bool = await viewModel.login()

        XCTAssertTrue(didLogin)
        XCTAssertEqual(authWebService.loginCallCount, 1)
        XCTAssertEqual(authWebService.lastLoginRequest?.email, "demo@example.com")
        XCTAssertEqual(authWebService.lastLoginRequest?.password, "password-123")
        XCTAssertEqual(secureStore.saveCredentialsCallCount, 1)
        XCTAssertEqual(secureStore.lastSavedCredentials?.accessToken, "response-access-token")
        XCTAssertEqual(secureStore.lastSavedCredentials?.refreshToken, "response-refresh-token")
        XCTAssertEqual(secureStore.lastSavedCredentials?.userPassword, "password-123")
        XCTAssertEqual(viewModel.accessTokenValue, "response-access-token")
        XCTAssertEqual(viewModel.refreshTokenValue, "response-refresh-token")
        XCTAssertEqual(viewModel.userPasswordValue, "password-123")
        XCTAssertEqual(
            viewModel.statusMessage,
            "Decoded LoginResponse from WebService and saved credentials into secure storage."
        )
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoginFailureSetsErrorMessage() async {
        let secureStore: MockSecureStoreService = MockSecureStoreService()
        let authWebService: MockAuthWebService = MockAuthWebService()
        authWebService.result = .failure(MockTestError.sampleFailure)
        let viewModel: AuthViewModel = AuthViewModel(
            secureStore: secureStore,
            authWebService: authWebService
        )

        let didLogin: Bool = await viewModel.login()

        XCTAssertFalse(didLogin)
        XCTAssertEqual(viewModel.statusMessage, "Sample failure.")
        XCTAssertFalse(viewModel.isLoading)
    }

    func testClearCredentialsResetsDisplayedValues() {
        let secureStore: MockSecureStoreService = MockSecureStoreService()
        secureStore.storedCredentials = AuthCredentials(
            accessToken: "stored-access-token",
            refreshToken: "stored-refresh-token",
            userPassword: "stored-password"
        )
        let authWebService: MockAuthWebService = MockAuthWebService()
        let viewModel: AuthViewModel = AuthViewModel(
            secureStore: secureStore,
            authWebService: authWebService
        )

        viewModel.clearCredentials()

        XCTAssertEqual(secureStore.clearCredentialsCallCount, 1)
        XCTAssertEqual(viewModel.accessTokenValue, "Not stored")
        XCTAssertEqual(viewModel.refreshTokenValue, "Not stored")
        XCTAssertEqual(viewModel.userPasswordValue, "Not stored")
        XCTAssertEqual(viewModel.statusMessage, "Removed all credentials from secure storage.")
    }
}
