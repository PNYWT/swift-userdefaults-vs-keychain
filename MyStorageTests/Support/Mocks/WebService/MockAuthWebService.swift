//
//  MockAuthWebService.swift
//  MyStorageTests
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation
@testable import MyStorage

final class MockAuthWebService: AuthWebServiceProtocol {
    var result: Result<LoginResponse, Error> = .success(
        LoginResponse(
            accessToken: "mock-access-token",
            refreshToken: "mock-refresh-token",
            tokenType: "Bearer",
            expiresIn: 3600
        )
    )
    var lastLoginRequest: LoginRequest?
    var loginCallCount: Int = 0

    func login(request: LoginRequest) async throws -> LoginResponse {
        loginCallCount += 1
        lastLoginRequest = request
        return try result.get()
    }
}
