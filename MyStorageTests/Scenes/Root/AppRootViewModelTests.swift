//
//  AppRootViewModelTests.swift
//  MyStorageTests
//
//  Created by Punyawat on 25/5/2569 BE.
//

import XCTest
@testable import MyStorage

@MainActor
final class AppRootViewModelTests: XCTestCase {
    func testInitWhenOnboardingIsIncompleteSetsRouteToOnboarding() {
        let appPreferences: MockAppPreferencesService = MockAppPreferencesService()
        appPreferences.hasCompletedOnboardingValue = false
        let secureStore: MockSecureStoreService = MockSecureStoreService()
        let localDatabase: MockLocalDatabase = MockLocalDatabase()

        let viewModel: AppRootViewModel = AppRootViewModel(
            appPreferences: appPreferences,
            secureStore: secureStore,
            localDatabase: localDatabase
        )

        XCTAssertEqual(viewModel.route, .onboarding)
    }

    func testInitWhenCredentialsExistSetsRouteToUserProfile() {
        let appPreferences: MockAppPreferencesService = MockAppPreferencesService()
        appPreferences.hasCompletedOnboardingValue = true
        let secureStore: MockSecureStoreService = MockSecureStoreService()
        secureStore.storedCredentials = AuthCredentials(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            userPassword: "password-123"
        )
        let localDatabase: MockLocalDatabase = MockLocalDatabase()

        let viewModel: AppRootViewModel = AppRootViewModel(
            appPreferences: appPreferences,
            secureStore: secureStore,
            localDatabase: localDatabase
        )

        XCTAssertEqual(viewModel.route, .userProfile)
    }

    func testInitWhenOnboardingCompletedAndNoCredentialsSetsRouteToAuth() {
        let appPreferences: MockAppPreferencesService = MockAppPreferencesService()
        appPreferences.hasCompletedOnboardingValue = true
        let secureStore: MockSecureStoreService = MockSecureStoreService()
        let localDatabase: MockLocalDatabase = MockLocalDatabase()

        let viewModel: AppRootViewModel = AppRootViewModel(
            appPreferences: appPreferences,
            secureStore: secureStore,
            localDatabase: localDatabase
        )

        XCTAssertEqual(viewModel.route, .auth)
    }

    func testShowOnboardingResetsPreferenceAndUpdatesRoute() {
        let appPreferences: MockAppPreferencesService = MockAppPreferencesService()
        appPreferences.hasCompletedOnboardingValue = true
        let secureStore: MockSecureStoreService = MockSecureStoreService()
        let localDatabase: MockLocalDatabase = MockLocalDatabase()
        let viewModel: AppRootViewModel = AppRootViewModel(
            appPreferences: appPreferences,
            secureStore: secureStore,
            localDatabase: localDatabase
        )

        viewModel.showOnboarding()

        XCTAssertEqual(appPreferences.lastSetHasCompletedOnboardingValue, false)
        XCTAssertEqual(viewModel.route, .onboarding)
    }

    func testSignOutClearsCredentialsAndLocalProfileThenRoutesToAuth() {
        let appPreferences: MockAppPreferencesService = MockAppPreferencesService()
        appPreferences.hasCompletedOnboardingValue = true
        let secureStore: MockSecureStoreService = MockSecureStoreService()
        secureStore.storedCredentials = AuthCredentials(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            userPassword: "password-123"
        )
        let localDatabase: MockLocalDatabase = MockLocalDatabase()
        let viewModel: AppRootViewModel = AppRootViewModel(
            appPreferences: appPreferences,
            secureStore: secureStore,
            localDatabase: localDatabase
        )

        viewModel.signOut()

        XCTAssertEqual(secureStore.clearCredentialsCallCount, 1)
        XCTAssertEqual(localDatabase.clearCallCount, 1)
        XCTAssertEqual(viewModel.route, .auth)
    }
}
