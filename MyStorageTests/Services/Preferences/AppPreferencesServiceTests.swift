//
//  AppPreferencesServiceTests.swift
//  MyStorageTests
//
//  Created by Punyawat on 25/5/2569 BE.
//

import XCTest
@testable import MyStorage

final class AppPreferencesServiceTests: XCTestCase {
    func testHasCompletedOnboardingReturnsStoredValue() {
        let userDefaultsManager: MockUserDefaultsManager = MockUserDefaultsManager()
        userDefaultsManager.boolValues[UserDefaultsKey.hasCompletedOnboarding] = true
        let service: AppPreferencesService = AppPreferencesService(userDefaultsManager: userDefaultsManager)

        let hasCompletedOnboarding: Bool = service.hasCompletedOnboarding()

        XCTAssertTrue(hasCompletedOnboarding)
    }

    func testSetHasCompletedOnboardingPersistsValue() {
        let userDefaultsManager: MockUserDefaultsManager = MockUserDefaultsManager()
        let service: AppPreferencesService = AppPreferencesService(userDefaultsManager: userDefaultsManager)

        service.setHasCompletedOnboarding(true)

        XCTAssertEqual(userDefaultsManager.boolValues[UserDefaultsKey.hasCompletedOnboarding], true)
    }
}
