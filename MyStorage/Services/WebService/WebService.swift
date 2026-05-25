//
//  WebService.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol WebServiceEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

extension WebServiceEndpoint {
    var queryItems: [URLQueryItem] { [] }
    var headers: [String: String] { [:] }
    var body: Data? { nil }
}

final class WebService {
    private let appConfig: AppConfig
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        appConfig: AppConfig,
        session: URLSession = .shared,
        decoder: JSONDecoder = WebService.makeDefaultDecoder()
    ) {
        self.appConfig = appConfig
        self.session = session
        self.decoder = decoder
    }

    func request<Response: Decodable>(_ endpoint: WebServiceEndpoint) async throws -> Response {
        let request: URLRequest = try buildRequest(for: endpoint)
        WebServiceLogger.logRequest(
            request,
            body: request.httpBody,
            shouldLog: appConfig.shouldLogNetwork
        )

        let rawResult: (Data, URLResponse) = try await session.data(for: request)

        guard let response: HTTPURLResponse = rawResult.1 as? HTTPURLResponse else {
            throw WebServiceError.invalidResponse
        }

        WebServiceLogger.logResponse(
            response: response,
            data: rawResult.0,
            shouldLog: appConfig.shouldLogNetwork
        )

        guard (200...299).contains(response.statusCode) else {
            throw WebServiceError.httpError(
                statusCode: response.statusCode,
                data: rawResult.0
            )
        }

        return try decoder.decode(Response.self, from: rawResult.0)
    }

    private func buildRequest(for endpoint: WebServiceEndpoint) throws -> URLRequest {
        let endpointURL: URL = appConfig.baseURL.appendingPathComponent(endpoint.path)

        guard var components: URLComponents = URLComponents(url: endpointURL, resolvingAgainstBaseURL: false) else {
            throw WebServiceError.invalidURL
        }

        components.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems

        guard let url: URL = components.url else {
            throw WebServiceError.invalidURL
        }

        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        let defaultHeaders: [String: String] = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]

        for (headerField, value) in defaultHeaders.merging(endpoint.headers, uniquingKeysWith: { _, new in new }) {
            request.setValue(value, forHTTPHeaderField: headerField)
        }

        return request
    }

    private static func makeDefaultDecoder() -> JSONDecoder {
        let decoder: JSONDecoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
