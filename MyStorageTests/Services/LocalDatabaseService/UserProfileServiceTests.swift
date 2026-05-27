//
//  UserProfileServiceTests.swift
//  MyStorageTests
//
//  Created by Punyawat on 25/5/2569 BE.
//

import XCTest
@testable import MyStorage

@MainActor
final class UserProfileServiceTests: XCTestCase {
    func testRefreshUserProfileWhenRemoteDataChangedSavesUpdatedProfile() async throws {
        let secureStore: MockSecureStoreService = MockSecureStoreService()
        secureStore.storedCredentials = AuthCredentials(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            userPassword: "password-123"
        )

        let localDatabase: MockLocalDatabase = MockLocalDatabase()
        localDatabase.cachedUserProfileValue = CachedUserProfile(
            id: 1,
            email: "before@example.com",
            displayName: "Before",
            updatedAt: Date(timeIntervalSince1970: 10)
        )

        let remoteUserProfile: UserProfile = UserProfile(
            id: 1,
            email: "after@example.com",
            displayName: "After",
            updatedAt: Date(timeIntervalSince1970: 20)
        )
        let webService: MockUserProfileWebService = MockUserProfileWebService()
        webService.result = .success(remoteUserProfile)

        let service: UserProfileService = UserProfileService(
            userProfileWebService: webService,
            secureStore: secureStore,
            localDatabase: localDatabase
        )

        let result: UserProfileRefreshResult = try await service.refreshUserProfile()

        XCTAssertEqual(result.source, .remoteUpdatedCache)
        XCTAssertEqual(result.userProfile, remoteUserProfile)
        XCTAssertEqual(localDatabase.saveCallCount, 1)
        XCTAssertEqual(localDatabase.savedUserProfile, remoteUserProfile)
    }

    func testRefreshUserProfileWhenRemoteDataIsUnchangedSkipsSave() async throws {
        let secureStore: MockSecureStoreService = MockSecureStoreService()
        secureStore.storedCredentials = AuthCredentials(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            userPassword: "password-123"
        )

        let cachedUserProfile: UserProfile = UserProfile(
            id: 2,
            email: "demo@example.com",
            displayName: "Demo",
            updatedAt: Date(timeIntervalSince1970: 30)
        )

        let localDatabase: MockLocalDatabase = MockLocalDatabase()
        localDatabase.cachedUserProfileValue = CachedUserProfile(userProfile: cachedUserProfile)

        let webService: MockUserProfileWebService = MockUserProfileWebService()
        webService.result = .success(cachedUserProfile)

        let service: UserProfileService = UserProfileService(
            userProfileWebService: webService,
            secureStore: secureStore,
            localDatabase: localDatabase
        )

        let result: UserProfileRefreshResult = try await service.refreshUserProfile()

        XCTAssertEqual(result.source, .remoteUnchanged)
        XCTAssertEqual(result.userProfile, cachedUserProfile)
        XCTAssertEqual(localDatabase.saveCallCount, 0)
    }

    func testRefreshUserProfileWhenRemoteFailsFallsBackToCachedValue() async throws {
        let secureStore: MockSecureStoreService = MockSecureStoreService()
        secureStore.storedCredentials = AuthCredentials(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            userPassword: "password-123"
        )

        let cachedUserProfile: UserProfile = UserProfile(
            id: 3,
            email: "cached@example.com",
            displayName: "Cached User",
            updatedAt: Date(timeIntervalSince1970: 40)
        )

        let localDatabase: MockLocalDatabase = MockLocalDatabase()
        localDatabase.cachedUserProfileValue = CachedUserProfile(userProfile: cachedUserProfile)

        let webService: MockUserProfileWebService = MockUserProfileWebService()
        webService.result = .failure(MockTestError.sampleFailure)

        let service: UserProfileService = UserProfileService(
            userProfileWebService: webService,
            secureStore: secureStore,
            localDatabase: localDatabase
        )

        let result: UserProfileRefreshResult = try await service.refreshUserProfile()

        XCTAssertEqual(result.source, .cachedFallback)
        XCTAssertEqual(result.userProfile, cachedUserProfile)
        XCTAssertEqual(localDatabase.saveCallCount, 0)
    }

    func testRefreshUserProfileWithoutCredentialsThrowsMissingCredentials() async {
        let secureStore: MockSecureStoreService = MockSecureStoreService()
        let localDatabase: MockLocalDatabase = MockLocalDatabase()
        let webService: MockUserProfileWebService = MockUserProfileWebService()
        let service: UserProfileService = UserProfileService(
            userProfileWebService: webService,
            secureStore: secureStore,
            localDatabase: localDatabase
        )

        do {
            _ = try await service.refreshUserProfile()
            XCTFail("Expected missing credentials error.")
        } catch let error as UserProfileServiceError {
            XCTAssertEqual(error, .missingCredentials)
        } catch {
            XCTFail("Received unexpected error: \(error)")
        }
    }
}
