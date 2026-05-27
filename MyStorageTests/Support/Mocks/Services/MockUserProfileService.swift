//
//  MockUserProfileService.swift
//  MyStorageTests
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation
@testable import MyStorage

@MainActor
final class MockUserProfileService: UserProfileServiceProtocol {
    var cachedUserProfileValue: UserProfile?
    var refreshResult: UserProfileRefreshResult?
    var cachedUserProfileError: Error?
    var refreshError: Error?
    var clearCachedUserProfileError: Error?
    var refreshCallCount: Int = 0
    var clearCallCount: Int = 0

    func cachedUserProfile() throws -> UserProfile? {
        if let cachedUserProfileError: Error = cachedUserProfileError {
            throw cachedUserProfileError
        }

        return cachedUserProfileValue
    }

    func refreshUserProfile() async throws -> UserProfileRefreshResult {
        refreshCallCount += 1

        if let refreshError: Error = refreshError {
            throw refreshError
        }

        guard let refreshResult: UserProfileRefreshResult = refreshResult else {
            fatalError("Expected refreshResult to be configured before calling refreshUserProfile().")
        }

        return refreshResult
    }

    func clearCachedUserProfile() throws {
        clearCallCount += 1

        if let clearCachedUserProfileError: Error = clearCachedUserProfileError {
            throw clearCachedUserProfileError
        }

        cachedUserProfileValue = nil
    }
}
