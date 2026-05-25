//
//  UserProfileService.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

enum UserProfileServiceError: LocalizedError {
    case missingCredentials

    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "No secure credentials were found. Please login first."
        }
    }
}

@MainActor
final class UserProfileService: UserProfileServiceProtocol {
    private let userProfileWebService: UserProfileWebServiceProtocol
    private let secureStore: SecureStoreServiceProtocol
    private let localDatabase: LocalDatabaseProtocol

    init(
        userProfileWebService: UserProfileWebServiceProtocol,
        secureStore: SecureStoreServiceProtocol,
        localDatabase: LocalDatabaseProtocol
    ) {
        self.userProfileWebService = userProfileWebService
        self.secureStore = secureStore
        self.localDatabase = localDatabase
    }

    convenience init() {
        self.init(
            userProfileWebService: UserProfileWebService(),
            secureStore: SecureStoreService(),
            localDatabase: LocalDatabase()
        )
    }

    func cachedUserProfile() throws -> UserProfile? {
        let cachedUserProfile: CachedUserProfile? = try localDatabase.cachedUserProfile()
        return cachedUserProfile?.userProfile
    }

    func refreshUserProfile() async throws -> UserProfileRefreshResult {
        let cachedUserProfile: UserProfile? = try self.cachedUserProfile()

        guard let credentials: AuthCredentials = try secureStore.loadCredentials() else {
            throw UserProfileServiceError.missingCredentials
        }

        do {
            let userProfile: UserProfile = try await userProfileWebService.fetchUserProfile(
                accessToken: credentials.accessToken
            )

            guard cachedUserProfile != userProfile else {
                return UserProfileRefreshResult(
                    userProfile: userProfile,
                    source: .remoteUnchanged
                )
            }

            try localDatabase.saveUserProfile(userProfile)

            return UserProfileRefreshResult(
                userProfile: userProfile,
                source: .remoteUpdatedCache
            )
        } catch {
            if let cachedUserProfile: UserProfile = cachedUserProfile {
                return UserProfileRefreshResult(
                    userProfile: cachedUserProfile,
                    source: .cachedFallback
                )
            }

            throw error
        }
    }

    func clearCachedUserProfile() throws {
        try localDatabase.clearUserProfile()
    }
}
