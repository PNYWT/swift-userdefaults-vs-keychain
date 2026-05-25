//
//  AppConfig.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

enum AppEnvironment {
    case development
    case production
}

struct AppConfig {
    let environment: AppEnvironment
    let baseURL: URL
    let shouldLogNetwork: Bool

    static let development: AppConfig = AppConfig(
        environment: .development,
        baseURL: URL(string: "https://dev.example.com")!,
        shouldLogNetwork: true
    )

    static let production: AppConfig = AppConfig(
        environment: .production,
        baseURL: URL(string: "https://api.example.com")!,
        shouldLogNetwork: false
    )

    static let current: AppConfig = .development
}
