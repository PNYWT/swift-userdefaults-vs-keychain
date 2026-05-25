//
//  UserProfileResponse.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

struct UserProfileResponse: Codable {
    let id: Int
    let email: String
    let displayName: String
    let updatedAt: Date
}
