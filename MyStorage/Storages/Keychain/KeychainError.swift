//
//  KeychainError.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation
import Security

enum KeychainError: Error, LocalizedError {
    case invalidStringEncoding
    case invalidItemData
    case unexpectedStatus(OSStatus)

    var errorDescription: String? {
        switch self {
        case .invalidStringEncoding:
            return "The provided string could not be converted to UTF-8 data."
        case .invalidItemData:
            return "The keychain item could not be decoded into the expected type."
        case let .unexpectedStatus(status):
            return "Keychain operation failed with status \(status)."
        }
    }
}
