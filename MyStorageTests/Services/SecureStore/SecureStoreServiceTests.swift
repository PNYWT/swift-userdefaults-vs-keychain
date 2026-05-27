//
//  SecureStoreServiceTests.swift
//  MyStorageTests
//
//  Created by Punyawat on 25/5/2569 BE.
//

import XCTest
@testable import MyStorage

final class SecureStoreServiceTests: XCTestCase {
    func testSaveCredentialsStoresAllSecureValues() throws {
        let keychainManager: MockKeychainManager = MockKeychainManager()
        let service: SecureStoreService = SecureStoreService(keychainManager: keychainManager)
        let credentials: AuthCredentials = AuthCredentials(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            userPassword: "password-123"
        )

        try service.saveCredentials(credentials)

        XCTAssertEqual(keychainManager.stringValues[KeychainKey.accessToken], "access-token")
        XCTAssertEqual(keychainManager.stringValues[KeychainKey.refreshToken], "refresh-token")
        XCTAssertEqual(keychainManager.stringValues[KeychainKey.userPassword], "password-123")
    }

    func testLoadCredentialsReturnsNilWhenARequiredValueIsMissing() throws {
        let keychainManager: MockKeychainManager = MockKeychainManager()
        keychainManager.stringValues[KeychainKey.accessToken] = "access-token"
        keychainManager.stringValues[KeychainKey.refreshToken] = "refresh-token"
        let service: SecureStoreService = SecureStoreService(keychainManager: keychainManager)

        let credentials: AuthCredentials? = try service.loadCredentials()

        XCTAssertNil(credentials)
    }

    func testClearCredentialsRemovesAllSecureValues() throws {
        let keychainManager: MockKeychainManager = MockKeychainManager()
        keychainManager.stringValues[KeychainKey.accessToken] = "access-token"
        keychainManager.stringValues[KeychainKey.refreshToken] = "refresh-token"
        keychainManager.stringValues[KeychainKey.userPassword] = "password-123"
        let service: SecureStoreService = SecureStoreService(keychainManager: keychainManager)

        try service.clearCredentials()

        XCTAssertEqual(
            keychainManager.removedKeys,
            [
                KeychainKey.accessToken,
                KeychainKey.refreshToken,
                KeychainKey.userPassword,
            ]
        )
    }
}
