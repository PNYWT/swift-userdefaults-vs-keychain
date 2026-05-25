//
//  OnboardingViewModel.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published private(set) var titleText: String = "UserDefaults Example"
    @Published private(set) var subtitleText: String = "Use AppPreferencesService for simple app state such as onboarding completion."

    private let appPreferences: AppPreferencesServiceProtocol

    init(appPreferences: AppPreferencesServiceProtocol) {
        self.appPreferences = appPreferences
    }

    convenience init() {
        self.init(appPreferences: AppPreferencesService())
    }

    func completeOnboarding() {
        appPreferences.setHasCompletedOnboarding(true)
    }
}
