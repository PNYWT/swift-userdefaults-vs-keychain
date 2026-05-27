//
//  MockLocalDatabase.swift
//  MyStorageTests
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation
@testable import MyStorage

@MainActor
final class MockLocalDatabase: LocalDatabaseProtocol {
    var cachedUserProfileValue: CachedUserProfile?
    var saveCallCount: Int = 0
    var clearCallCount: Int = 0
    var savedUserProfile: UserProfile?

    func cachedUserProfile() throws -> CachedUserProfile? {
        cachedUserProfileValue
    }

    func saveUserProfile(_ userProfile: UserProfile) throws {
        saveCallCount += 1
        savedUserProfile = userProfile
        cachedUserProfileValue = CachedUserProfile(userProfile: userProfile)
    }

    func clearUserProfile() throws {
        clearCallCount += 1
        cachedUserProfileValue = nil
    }
}
