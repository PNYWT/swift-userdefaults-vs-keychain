//
//  LocalDatabaseProtocol.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

@MainActor
protocol LocalDatabaseProtocol {
    func cachedUserProfile() throws -> CachedUserProfile?
    func saveUserProfile(_ userProfile: UserProfile) throws
    func clearUserProfile() throws
}
