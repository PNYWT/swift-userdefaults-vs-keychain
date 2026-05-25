//
//  AppPreferencesService.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

final class AppPreferencesService: AppPreferencesServiceProtocol {
    private let userDefaultsManager: UserDefaultsManagerProtocol

    init(userDefaultsManager: UserDefaultsManagerProtocol) {
        self.userDefaultsManager = userDefaultsManager
    }

    convenience init() {
        self.init(userDefaultsManager: UserDefaultsManager())
    }

    func hasCompletedOnboarding() -> Bool {
        userDefaultsManager.bool(forKey: UserDefaultsKey.hasCompletedOnboarding)
    }

    func setHasCompletedOnboarding(_ value: Bool) {
        userDefaultsManager.set(value, forKey: UserDefaultsKey.hasCompletedOnboarding)
    }
}
