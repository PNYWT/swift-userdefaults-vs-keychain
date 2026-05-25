//
//  SecureStoreService.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

final class SecureStoreService: SecureStoreServiceProtocol {
    private let keychainManager: KeychainManagerProtocol

    init(keychainManager: KeychainManagerProtocol) {
        self.keychainManager = keychainManager
    }

    convenience init() {
        self.init(keychainManager: KeychainManager())
    }

    func loadCredentials() throws -> AuthCredentials? {
        let accessToken: String? = try keychainManager.string(forKey: KeychainKey.accessToken)
        let refreshToken: String? = try keychainManager.string(forKey: KeychainKey.refreshToken)
        let userPassword: String? = try keychainManager.string(forKey: KeychainKey.userPassword)

        guard
            let accessToken: String = accessToken,
            let refreshToken: String = refreshToken,
            let userPassword: String = userPassword
        else {
            return nil
        }

        return AuthCredentials(
            accessToken: accessToken,
            refreshToken: refreshToken,
            userPassword: userPassword
        )
    }

    func saveCredentials(_ credentials: AuthCredentials) throws {
        try keychainManager.set(credentials.accessToken, forKey: KeychainKey.accessToken)
        try keychainManager.set(credentials.refreshToken, forKey: KeychainKey.refreshToken)
        try keychainManager.set(credentials.userPassword, forKey: KeychainKey.userPassword)
    }

    func clearCredentials() throws {
        try keychainManager.remove(forKey: KeychainKey.accessToken)
        try keychainManager.remove(forKey: KeychainKey.refreshToken)
        try keychainManager.remove(forKey: KeychainKey.userPassword)
    }
}
