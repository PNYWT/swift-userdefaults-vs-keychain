//
//  MockTestError.swift
//  MyStorageTests
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

enum MockTestError: LocalizedError {
    case sampleFailure

    var errorDescription: String? {
        switch self {
        case .sampleFailure:
            return "Sample failure."
        }
    }
}
