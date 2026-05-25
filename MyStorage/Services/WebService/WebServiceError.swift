//
//  WebServiceError.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

enum WebServiceError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The web service could not build a valid URL."
        case .invalidResponse:
            return "The web service returned an invalid response."
        case let .httpError(statusCode, _):
            return "The server responded with status code \(statusCode)."
        }
    }
}
