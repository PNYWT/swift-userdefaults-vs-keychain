//
//  UserProfileWebService.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

protocol UserProfileWebServiceProtocol {
    func fetchUserProfile(accessToken: String) async throws -> UserProfile
}

private enum UserProfileEndpoint: WebServiceEndpoint {
    case currentUser(accessToken: String)

    var path: String {
        switch self {
        case .currentUser:
            return "users/me"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .currentUser:
            return .get
        }
    }

    var headers: [String: String] {
        switch self {
        case let .currentUser(accessToken):
            return ["Authorization": "Bearer \(accessToken)"]
        }
    }
}

final class UserProfileWebService: UserProfileWebServiceProtocol {
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

    func fetchUserProfile(accessToken: String) async throws -> UserProfile {
        switch appConfig.environment {
        case .development:
            return try await mockUserProfile(accessToken: accessToken)
        case .production:
            let response: UserProfileResponse = try await webService.request(
                UserProfileEndpoint.currentUser(accessToken: accessToken)
            )
            return UserProfile(response: response)
        }
    }

    private func mockUserProfile(accessToken: String) async throws -> UserProfile {
        try await Task.sleep(nanoseconds: 250_000_000)

        let endpoint: UserProfileEndpoint = .currentUser(accessToken: accessToken)
        let requestURL: URL = appConfig.baseURL.appendingPathComponent(endpoint.path)
        var urlRequest: URLRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        for (headerField, value) in endpoint.headers {
            urlRequest.setValue(value, forHTTPHeaderField: headerField)
        }

        WebServiceLogger.logRequest(
            urlRequest,
            body: urlRequest.httpBody,
            shouldLog: appConfig.shouldLogNetwork
        )

        let tokenSuffix: String = String(accessToken.suffix(6))
        let mockJSON: String = """
        {
          "id": 101,
          "email": "demo@example.com",
          "displayName": "Punyawat \(tokenSuffix)",
          "updatedAt": "2026-05-25T12:00:00Z"
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

        let decoder: JSONDecoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let responseObject: UserProfileResponse = try decoder.decode(UserProfileResponse.self, from: data)
        return UserProfile(response: responseObject)
    }
}
