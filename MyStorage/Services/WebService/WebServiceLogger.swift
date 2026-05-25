//
//  WebServiceLogger.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

enum WebServiceLogger {
    private static let sensitiveKeys: Set<String> = [
        "password",
        "accesstoken",
        "refreshtoken",
        "authorization",
        "apikey",
        "token",
        "secret"
    ]

    static func logRequest(
        _ request: URLRequest,
        body: Data?,
        shouldLog: Bool
    ) {
        guard shouldLog else {
            return
        }

        let method: String = request.httpMethod ?? "UNKNOWN"
        let url: String = request.url?.absoluteString ?? "unknown-url"
        let headers: [String: String] = maskedHeaders(request.allHTTPHeaderFields ?? [:])
        let bodyDescription: String = maskedBodyString(from: body)

        print(
            """
            [WebService] Request
            method: \(method)
            url: \(url)
            headers: \(headers)
            body: \(bodyDescription)
            """
        )
    }

    static func logResponse(
        response: HTTPURLResponse,
        data: Data,
        shouldLog: Bool
    ) {
        guard shouldLog else {
            return
        }

        let url: String = response.url?.absoluteString ?? "unknown-url"
        let bodyDescription: String = maskedBodyString(from: data)

        print(
            """
            [WebService] Response
            status: \(response.statusCode)
            url: \(url)
            body: \(bodyDescription)
            """
        )
    }

    private static func maskedHeaders(_ headers: [String: String]) -> [String: String] {
        var maskedHeaders: [String: String] = headers

        for (key, value) in headers {
            if isSensitive(key: key) {
                maskedHeaders[key] = maskedValue(value)
            }
        }

        return maskedHeaders
    }

    private static func maskedBodyString(from data: Data?) -> String {
        guard let data: Data = data, data.isEmpty == false else {
            return "nil"
        }

        if
            let object: Any = try? JSONSerialization.jsonObject(with: data),
            let maskedObject: Any = maskJSONValue(object)
        {
            let options: JSONSerialization.WritingOptions = [.prettyPrinted, .sortedKeys]

            if
                let maskedData: Data = try? JSONSerialization.data(withJSONObject: maskedObject, options: options),
                let maskedString: String = String(data: maskedData, encoding: .utf8)
            {
                return maskedString
            }
        }

        guard let rawString: String = String(data: data, encoding: .utf8) else {
            return "<non-utf8-data>"
        }

        return rawString
    }

    private static func maskJSONValue(_ value: Any, key: String? = nil) -> Any? {
        if let dictionary: [String: Any] = value as? [String: Any] {
            var maskedDictionary: [String: Any] = [:]

            for (dictionaryKey, dictionaryValue) in dictionary {
                maskedDictionary[dictionaryKey] = maskJSONValue(dictionaryValue, key: dictionaryKey)
            }

            return maskedDictionary
        }

        if let array: [Any] = value as? [Any] {
            return array.map { maskJSONValue($0) ?? $0 }
        }

        if let stringValue: String = value as? String, let key: String = key, isSensitive(key: key) {
            return maskedValue(stringValue)
        }

        return value
    }

    private static func isSensitive(key: String) -> Bool {
        sensitiveKeys.contains(key.lowercased())
    }

    private static func maskedValue(_ value: String) -> String {
        guard value.isEmpty == false else {
            return value
        }

        let visibleCount: Int = min(3, value.count)
        let visiblePrefix: String = String(value.prefix(visibleCount))
        return "\(visiblePrefix)********"
    }
}
