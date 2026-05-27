//
//  LocalDatabaseIntegrationTests.swift
//  MyStorageTests
//
//  Created by Punyawat on 25/5/2569 BE.
//

import XCTest
import SwiftData
@testable import MyStorage

@MainActor
final class LocalDatabaseIntegrationTests: XCTestCase {
    func testSaveAndReadCachedUserProfile() throws {
        let localDatabase: LocalDatabase = try makeLocalDatabase()
        let userProfile: UserProfile = UserProfile(
            id: 1,
            email: "demo@example.com",
            displayName: "Demo User",
            updatedAt: Date(timeIntervalSince1970: 100)
        )

        try localDatabase.saveUserProfile(userProfile)

        let cachedUserProfile: CachedUserProfile? = try localDatabase.cachedUserProfile()

        XCTAssertEqual(cachedUserProfile?.userProfile, userProfile)
    }

    func testSaveUserProfileReplacesPreviousCachedValue() throws {
        let localDatabase: LocalDatabase = try makeLocalDatabase()
        let firstUserProfile: UserProfile = UserProfile(
            id: 1,
            email: "first@example.com",
            displayName: "First User",
            updatedAt: Date(timeIntervalSince1970: 100)
        )
        let secondUserProfile: UserProfile = UserProfile(
            id: 2,
            email: "second@example.com",
            displayName: "Second User",
            updatedAt: Date(timeIntervalSince1970: 200)
        )

        try localDatabase.saveUserProfile(firstUserProfile)
        try localDatabase.saveUserProfile(secondUserProfile)

        let cachedUserProfile: CachedUserProfile? = try localDatabase.cachedUserProfile()

        XCTAssertEqual(cachedUserProfile?.userProfile, secondUserProfile)
    }

    func testClearUserProfileRemovesCachedValue() throws {
        let localDatabase: LocalDatabase = try makeLocalDatabase()
        let userProfile: UserProfile = UserProfile(
            id: 3,
            email: "clear@example.com",
            displayName: "Clear User",
            updatedAt: Date(timeIntervalSince1970: 300)
        )

        try localDatabase.saveUserProfile(userProfile)
        try localDatabase.clearUserProfile()

        let cachedUserProfile: CachedUserProfile? = try localDatabase.cachedUserProfile()

        XCTAssertNil(cachedUserProfile)
    }

    private func makeLocalDatabase() throws -> LocalDatabase {
        let configuration: ModelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
        let modelContainer: ModelContainer = try ModelContainer(
            for: CachedUserProfile.self,
            configurations: configuration
        )

        return LocalDatabase(modelContainer: modelContainer)
    }
}
