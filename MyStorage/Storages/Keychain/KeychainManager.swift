//
//  KeychainManager.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation
import Security

final class KeychainManager: KeychainManagerProtocol {
    private let configuration: KeychainConfiguration

    init(
        configuration: KeychainConfiguration = .default
    ) {
        self.configuration = configuration
    }

    func data(forKey key: String) throws -> Data? {
        let query: [String: Any] = baseQuery(forKey: key).merging(
            [
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne,
            ],
            uniquingKeysWith: { _, new in new }
        )

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.invalidItemData
            }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    func string(forKey key: String) throws -> String? {
        guard let data: Data = try data(forKey: key) else {
            return nil
        }

        guard let value: String = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidItemData
        }

        return value
    }

    func set(_ value: Data, forKey key: String) throws {
        let query: [String: Any] = baseQuery(forKey: key)
        let addQuery: [String: Any] = query.merging(
            [
                kSecValueData as String: value,
                kSecAttrAccessible as String: configuration.accessibleAttribute,
            ],
            uniquingKeysWith: { _, new in new }
        )

        let addStatus: OSStatus = SecItemAdd(addQuery as CFDictionary, nil)

        switch addStatus {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            let attributesToUpdate: [String: Any] = [kSecValueData as String: value]
            let updateStatus: OSStatus = SecItemUpdate(
                query as CFDictionary,
                attributesToUpdate as CFDictionary
            )

            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(addStatus)
        }
    }

    func set(_ value: String, forKey key: String) throws {
        guard let data: Data = value.data(using: .utf8) else {
            throw KeychainError.invalidStringEncoding
        }

        try set(data, forKey: key)
    }

    func remove(forKey key: String) throws {
        let status = SecItemDelete(baseQuery(forKey: key) as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    private func baseQuery(forKey key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: configuration.service,
            kSecAttrAccount as String: key,
        ]
    }
}
