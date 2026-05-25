//
//  StorageKeys.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

enum AppStorageConfiguration {
    // Keep this value stable across releases or existing Keychain items will become unreadable.
    static let keychainService: String = "com.companyname.appname"
    static let localDatabaseName: String = "MyStorageLocalDatabase"
}

enum UserDefaultsKey {
    static let hasCompletedOnboarding: String = "has_completed_onboarding"
}

enum KeychainKey {
    static let accessToken: String = "access_token"
    static let refreshToken: String = "refresh_token"
    static let userPassword: String = "user_password"
}
