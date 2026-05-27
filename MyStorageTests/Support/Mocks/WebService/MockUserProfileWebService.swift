//
//  MockUserProfileWebService.swift
//  MyStorageTests
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation
@testable import MyStorage

@MainActor
final class MockUserProfileWebService: UserProfileWebServiceProtocol {
    var result: Result<UserProfile, Error> = .success(
        UserProfile(
            id: 0,
            email: "",
            displayName: "",
            updatedAt: Date(timeIntervalSince1970: 0)
        )
    )
    var fetchCallCount: Int = 0
    var lastAccessToken: String?

    func fetchUserProfile(accessToken: String) async throws -> UserProfile {
        fetchCallCount += 1
        lastAccessToken = accessToken
        return try result.get()
    }
}
