//
//  MockAppPreferencesService.swift
//  MyStorageTests
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation
@testable import MyStorage

final class MockAppPreferencesService: AppPreferencesServiceProtocol {
    var hasCompletedOnboardingValue: Bool = false
    var lastSetHasCompletedOnboardingValue: Bool?

    func hasCompletedOnboarding() -> Bool {
        hasCompletedOnboardingValue
    }

    func setHasCompletedOnboarding(_ value: Bool) {
        lastSetHasCompletedOnboardingValue = value
        hasCompletedOnboardingValue = value
    }
}
