//
//  MockUserDefaultsManager.swift
//  MyStorageTests
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation
@testable import MyStorage

final class MockUserDefaultsManager: UserDefaultsManagerProtocol {
    var boolValues: [String: Bool] = [:]
    var stringValues: [String: String] = [:]

    func bool(forKey key: String) -> Bool {
        boolValues[key] ?? false
    }

    func string(forKey key: String) -> String? {
        stringValues[key]
    }

    func set(_ value: Bool, forKey key: String) {
        boolValues[key] = value
    }

    func set(_ value: String, forKey key: String) {
        stringValues[key] = value
    }

    func remove(forKey key: String) {
        boolValues.removeValue(forKey: key)
        stringValues.removeValue(forKey: key)
    }
}
