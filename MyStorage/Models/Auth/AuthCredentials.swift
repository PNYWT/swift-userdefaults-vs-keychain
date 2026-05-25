//
//  AuthCredentials.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

struct AuthCredentials {
    let accessToken: String
    let refreshToken: String
    let userPassword: String

    init(
        accessToken: String,
        refreshToken: String,
        userPassword: String
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.userPassword = userPassword
    }

    init(loginResponse: LoginResponse, userPassword: String) {
        self.accessToken = loginResponse.accessToken
        self.refreshToken = loginResponse.refreshToken
        self.userPassword = userPassword
    }
}
