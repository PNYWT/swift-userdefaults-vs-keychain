//
//  MockKeychainManager.swift
//  MyStorageTests
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation
@testable import MyStorage

final class MockKeychainManager: KeychainManagerProtocol {
    var dataValues: [String: Data] = [:]
    var stringValues: [String: String] = [:]
    var removedKeys: [String] = []

    func data(forKey key: String) throws -> Data? {
        dataValues[key]
    }

    func string(forKey key: String) throws -> String? {
        stringValues[key]
    }

    func set(_ value: Data, forKey key: String) throws {
        dataValues[key] = value
    }

    func set(_ value: String, forKey key: String) throws {
        stringValues[key] = value
    }

    func remove(forKey key: String) throws {
        removedKeys.append(key)
        dataValues.removeValue(forKey: key)
        stringValues.removeValue(forKey: key)
    }
}
