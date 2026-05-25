//
//  UserProfile.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

struct UserProfile: Identifiable, Equatable {
    let id: Int
    let email: String
    let displayName: String
    let updatedAt: Date

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

    init(response: UserProfileResponse) {
        self.id = response.id
        self.email = response.email
        self.displayName = response.displayName
        self.updatedAt = response.updatedAt
    }
}
