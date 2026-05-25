//
//  CachedUserProfile.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation
import SwiftData

@Model
final class CachedUserProfile {
    @Attribute(.unique) var id: Int
    var email: String
    var displayName: String
    var updatedAt: Date

    init(
        id: Int,
        email: String,
        displayName: String,
        updatedAt: Date
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.updatedAt = updatedAt
    }

    convenience init(userProfile: UserProfile) {
        self.init(
            id: userProfile.id,
            email: userProfile.email,
            displayName: userProfile.displayName,
            updatedAt: userProfile.updatedAt
        )
    }

    var userProfile: UserProfile {
        UserProfile(
            id: id,
            email: email,
            displayName: displayName,
            updatedAt: updatedAt
        )
    }
}
