//
//  KeychainManagerIntegrationTests.swift
//  MyStorageTests
//
//  Created by Punyawat on 25/5/2569 BE.
//

import XCTest
import Security
@testable import MyStorage

final class KeychainManagerIntegrationTests: XCTestCase {
    func testSetAndReadStringValue() throws {
        let serviceName: String = "com.companyname.appname.tests.\(UUID().uuidString)"
        let key: String = "integration_access_token"
        let value: String = "integration-token-123"
        let keychainManager: KeychainManager = makeKeychainManager(serviceName: serviceName)

        defer {
            try? keychainManager.remove(forKey: key)
        }

        try keychainManager.set(value, forKey: key)

        let storedValue: String? = try keychainManager.string(forKey: key)

        XCTAssertEqual(storedValue, value)
    }

    func testSetWhenValueAlreadyExistsUpdatesStoredValue() throws {
        let serviceName: String = "com.companyname.appname.tests.\(UUID().uuidString)"
        let key: String = "integration_refresh_token"
        let originalValue: String = "refresh-token-old"
        let updatedValue: String = "refresh-token-new"
        let keychainManager: KeychainManager = makeKeychainManager(serviceName: serviceName)

        defer {
            try? keychainManager.remove(forKey: key)
        }

        try keychainManager.set(originalValue, forKey: key)
        try keychainManager.set(updatedValue, forKey: key)

        let storedValue: String? = try keychainManager.string(forKey: key)

        XCTAssertEqual(storedValue, updatedValue)
    }

    func testRemoveDeletesStoredValue() throws {
        let serviceName: String = "com.companyname.appname.tests.\(UUID().uuidString)"
        let key: String = "integration_user_password"
        let keychainManager: KeychainManager = makeKeychainManager(serviceName: serviceName)

        try keychainManager.set("password-123", forKey: key)

        try keychainManager.remove(forKey: key)

        let storedValue: String? = try keychainManager.string(forKey: key)

        XCTAssertNil(storedValue)
    }

    private func makeKeychainManager(serviceName: String) -> KeychainManager {
        let configuration: KeychainConfiguration = KeychainConfiguration(
            service: serviceName,
            accessibleAttribute: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        )

        return KeychainManager(configuration: configuration)
    }
}
