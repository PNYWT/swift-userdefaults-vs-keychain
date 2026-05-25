//
//  UserDefaultsManager.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

final class UserDefaultsManager: UserDefaultsManagerProtocol {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func bool(forKey key: String) -> Bool {
        userDefaults.bool(forKey: key)
    }

    func string(forKey key: String) -> String? {
        userDefaults.string(forKey: key)
    }

    func set(_ value: Bool, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func set(_ value: String, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
