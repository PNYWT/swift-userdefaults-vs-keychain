//
//  UserProfileServiceProtocol.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

enum UserProfileRefreshSource: Equatable {
    case remoteUpdatedCache
    case remoteUnchanged
    case cachedFallback
}

struct UserProfileRefreshResult {
    let userProfile: UserProfile
    let source: UserProfileRefreshSource
}

@MainActor
protocol UserProfileServiceProtocol {
    func cachedUserProfile() throws -> UserProfile?
    func refreshUserProfile() async throws -> UserProfileRefreshResult
    func clearCachedUserProfile() throws
}
