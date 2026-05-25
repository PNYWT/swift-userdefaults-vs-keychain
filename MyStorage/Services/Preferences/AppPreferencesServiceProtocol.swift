//
//  AppPreferencesServiceProtocol.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation

protocol AppPreferencesServiceProtocol {
    func hasCompletedOnboarding() -> Bool
    func setHasCompletedOnboarding(_ value: Bool)
}
