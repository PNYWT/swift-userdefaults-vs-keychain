//
//  AppRootViewModel.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation
import Combine

@MainActor
final class AppRootViewModel: ObservableObject {
    enum Route: Equatable {
        case onboarding
        case auth
        case userProfile
    }

    @Published private(set) var route: Route

    private let appPreferences: AppPreferencesServiceProtocol
    private let secureStore: SecureStoreServiceProtocol
    private let localDatabase: LocalDatabaseProtocol

    init(
        appPreferences: AppPreferencesServiceProtocol,
        secureStore: SecureStoreServiceProtocol,
        localDatabase: LocalDatabaseProtocol
    ) {
        self.appPreferences = appPreferences
        self.secureStore = secureStore
        self.localDatabase = localDatabase
        self.route = Self.resolveRoute(
            appPreferences: appPreferences,
            secureStore: secureStore
        )
    }

    convenience init() {
        self.init(
            appPreferences: AppPreferencesService(),
            secureStore: SecureStoreService(),
            localDatabase: LocalDatabase()
        )
    }

    func refreshRoute() {
        route = Self.resolveRoute(
            appPreferences: appPreferences,
            secureStore: secureStore
        )
    }

    func showAuth() {
        route = .auth
    }

    func showUserProfile() {
        route = .userProfile
    }

    func showOnboarding() {
        appPreferences.setHasCompletedOnboarding(false)
        route = .onboarding
    }

    func signOut() {
        do {
            try secureStore.clearCredentials()
            try localDatabase.clearUserProfile()
        } catch {
            print("Failed to sign out cleanly: \(error)")
        }

        route = .auth
    }

    private static func resolveRoute(
        appPreferences: AppPreferencesServiceProtocol,
        secureStore: SecureStoreServiceProtocol
    ) -> Route {
        guard appPreferences.hasCompletedOnboarding() else {
            return .onboarding
        }

        do {
            if try secureStore.loadCredentials() != nil {
                return .userProfile
            }
        } catch {
            return .auth
        }

        return .auth
    }
}
