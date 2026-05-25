//
//  AuthWebService.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

protocol AuthWebServiceProtocol {
    func login(request: LoginRequest) async throws -> LoginResponse
}

enum AuthEndpoint: WebServiceEndpoint {
    case login(LoginRequest)

    var path: String {
        switch self {
        case .login:
            return "auth/login"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        }
    }

    var body: Data? {
        switch self {
        case let .login(request):
            return try? JSONEncoder().encode(request)
        }
    }
}

final class AuthWebService: AuthWebServiceProtocol {
    private let appConfig: AppConfig
    private let webService: WebService

    init(
        appConfig: AppConfig,
        webService: WebService
    ) {
        self.appConfig = appConfig
        self.webService = webService
    }

    convenience init(
        appConfig: AppConfig = .current
    ) {
        self.init(
            appConfig: appConfig,
            webService: WebService(appConfig: appConfig)
        )
    }

    func login(request: LoginRequest) async throws -> LoginResponse {
        switch appConfig.environment {
        case .development:
            return try await mockLoginResponse(for: request)
        case .production:
            return try await webService.request(AuthEndpoint.login(request))
        }
    }

    private func mockLoginResponse(for request: LoginRequest) async throws -> LoginResponse {
        try await Task.sleep(nanoseconds: 300_000_000)

        let requestURL: URL = appConfig.baseURL.appendingPathComponent(AuthEndpoint.login(request).path)
        var urlRequest: URLRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = AuthEndpoint.login(request).method.rawValue
        urlRequest.httpBody = AuthEndpoint.login(request).body
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        WebServiceLogger.logRequest(
            urlRequest,
            body: urlRequest.httpBody,
            shouldLog: appConfig.shouldLogNetwork
        )

        let sanitizedEmail: String = request.email
            .lowercased()
            .replacingOccurrences(of: "@", with: "_at_")
            .replacingOccurrences(of: ".", with: "_dot_")

        let mockJSON: String = """
        {
          "accessToken": "access_\(sanitizedEmail)_123456",
          "refreshToken": "refresh_\(sanitizedEmail)_654321",
          "tokenType": "Bearer",
          "expiresIn": 3600
        }
        """

        guard let data: Data = mockJSON.data(using: .utf8) else {
            throw WebServiceError.invalidResponse
        }

        let response: HTTPURLResponse = HTTPURLResponse(
            url: requestURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!

        WebServiceLogger.logResponse(
            response: response,
            data: data,
            shouldLog: appConfig.shouldLogNetwork
        )

        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }
}
