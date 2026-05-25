//
//  UserProfileViewModel.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation
import Combine

@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published private(set) var displayNameValue: String = "Not cached"
    @Published private(set) var emailValue: String = "Not cached"
    @Published private(set) var updatedAtValue: String = "Not cached"
    @Published private(set) var statusMessage: String = "No profile loaded yet."
    @Published private(set) var isLoading: Bool = false

    private let userProfileService: UserProfileServiceProtocol
    private let dateFormatter: DateFormatter

    init(userProfileService: UserProfileServiceProtocol) {
        self.userProfileService = userProfileService

        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        self.dateFormatter = dateFormatter

        loadCachedUserProfile()
    }

    convenience init() {
        self.init(userProfileService: UserProfileService())
    }

    func refreshUserProfile() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let refreshResult: UserProfileRefreshResult = try await userProfileService.refreshUserProfile()
            apply(refreshResult.userProfile)

            switch refreshResult.source {
            case .remoteUpdatedCache:
                statusMessage = "Fetched protected profile data from WebService and updated the local database."
            case .remoteUnchanged:
                statusMessage = "Fetched protected profile data from WebService. The local cache was already up to date."
            case .cachedFallback:
                statusMessage = "The network request failed, so the app is showing the cached user profile from the local database."
            }
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    func loadCachedUserProfile() {
        do {
            guard let userProfile: UserProfile = try userProfileService.cachedUserProfile() else {
                resetDisplayedValues()
                statusMessage = "No cached profile was found in the local database."
                return
            }

            apply(userProfile)
            statusMessage = "Loaded user profile from the local database."
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    func clearCachedUserProfile() {
        do {
            try userProfileService.clearCachedUserProfile()
            resetDisplayedValues()
            statusMessage = "Removed cached user profile from the local database."
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func apply(_ userProfile: UserProfile) {
        displayNameValue = userProfile.displayName
        emailValue = userProfile.email
        updatedAtValue = dateFormatter.string(from: userProfile.updatedAt)
    }

    private func resetDisplayedValues() {
        displayNameValue = "Not cached"
        emailValue = "Not cached"
        updatedAtValue = "Not cached"
    }
}
