//
//  MockSecureStoreService.swift
//  MyStorageTests
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation
@testable import MyStorage

@MainActor
final class MockSecureStoreService: SecureStoreServiceProtocol {
    var storedCredentials: AuthCredentials?
    var loadCredentialsCallCount: Int = 0
    var saveCredentialsCallCount: Int = 0
    var clearCredentialsCallCount: Int = 0
    var loadCredentialsError: Error?
    var saveCredentialsError: Error?
    var clearCredentialsError: Error?
    var lastSavedCredentials: AuthCredentials?

    func loadCredentials() throws -> AuthCredentials? {
        loadCredentialsCallCount += 1

        if let loadCredentialsError: Error = loadCredentialsError {
            throw loadCredentialsError
        }

        return storedCredentials
    }

    func saveCredentials(_ credentials: AuthCredentials) throws {
        saveCredentialsCallCount += 1

        if let saveCredentialsError: Error = saveCredentialsError {
            throw saveCredentialsError
        }

        lastSavedCredentials = credentials
        storedCredentials = credentials
    }

    func clearCredentials() throws {
        clearCredentialsCallCount += 1

        if let clearCredentialsError: Error = clearCredentialsError {
            throw clearCredentialsError
        }

        storedCredentials = nil
    }
}
