//
//  UserProfileViewModelTests.swift
//  MyStorageTests
//
//  Created by Punyawat on 25/5/2569 BE.
//

import XCTest
@testable import MyStorage

@MainActor
final class UserProfileViewModelTests: XCTestCase {
    func testInitWhenCachedProfileExistsLoadsDisplayedValues() {
        let cachedUserProfile: UserProfile = UserProfile(
            id: 1,
            email: "cached@example.com",
            displayName: "Cached User",
            updatedAt: Date(timeIntervalSince1970: 100)
        )
        let userProfileService: MockUserProfileService = MockUserProfileService()
        userProfileService.cachedUserProfileValue = cachedUserProfile

        let viewModel: UserProfileViewModel = UserProfileViewModel(userProfileService: userProfileService)

        XCTAssertEqual(viewModel.displayNameValue, "Cached User")
        XCTAssertEqual(viewModel.emailValue, "cached@example.com")
        XCTAssertEqual(viewModel.updatedAtValue, formattedDateString(for: cachedUserProfile.updatedAt))
        XCTAssertEqual(viewModel.statusMessage, "Loaded user profile from the local database.")
    }

    func testInitWhenNoCachedProfileShowsEmptyState() {
        let userProfileService: MockUserProfileService = MockUserProfileService()

        let viewModel: UserProfileViewModel = UserProfileViewModel(userProfileService: userProfileService)

        XCTAssertEqual(viewModel.displayNameValue, "Not cached")
        XCTAssertEqual(viewModel.emailValue, "Not cached")
        XCTAssertEqual(viewModel.updatedAtValue, "Not cached")
        XCTAssertEqual(viewModel.statusMessage, "No cached profile was found in the local database.")
    }

    func testRefreshUserProfileWhenRemoteUpdatedCacheSetsSuccessStatus() async {
        let refreshedUserProfile: UserProfile = UserProfile(
            id: 2,
            email: "remote@example.com",
            displayName: "Remote User",
            updatedAt: Date(timeIntervalSince1970: 200)
        )
        let userProfileService: MockUserProfileService = MockUserProfileService()
        userProfileService.refreshResult = UserProfileRefreshResult(
            userProfile: refreshedUserProfile,
            source: .remoteUpdatedCache
        )
        let viewModel: UserProfileViewModel = UserProfileViewModel(userProfileService: userProfileService)

        await viewModel.refreshUserProfile()

        XCTAssertEqual(userProfileService.refreshCallCount, 1)
        XCTAssertEqual(viewModel.displayNameValue, "Remote User")
        XCTAssertEqual(viewModel.emailValue, "remote@example.com")
        XCTAssertEqual(viewModel.updatedAtValue, formattedDateString(for: refreshedUserProfile.updatedAt))
        XCTAssertEqual(
            viewModel.statusMessage,
            "Fetched protected profile data from WebService and updated the local database."
        )
        XCTAssertFalse(viewModel.isLoading)
    }

    func testRefreshUserProfileWhenFallbackToCachedValueSetsFallbackStatus() async {
        let cachedUserProfile: UserProfile = UserProfile(
            id: 3,
            email: "cached@example.com",
            displayName: "Cached User",
            updatedAt: Date(timeIntervalSince1970: 300)
        )
        let userProfileService: MockUserProfileService = MockUserProfileService()
        userProfileService.refreshResult = UserProfileRefreshResult(
            userProfile: cachedUserProfile,
            source: .cachedFallback
        )
        let viewModel: UserProfileViewModel = UserProfileViewModel(userProfileService: userProfileService)

        await viewModel.refreshUserProfile()

        XCTAssertEqual(viewModel.displayNameValue, "Cached User")
        XCTAssertEqual(
            viewModel.statusMessage,
            "The network request failed, so the app is showing the cached user profile from the local database."
        )
        XCTAssertFalse(viewModel.isLoading)
    }

    func testClearCachedUserProfileResetsDisplayedValues() {
        let cachedUserProfile: UserProfile = UserProfile(
            id: 4,
            email: "cached@example.com",
            displayName: "Cached User",
            updatedAt: Date(timeIntervalSince1970: 400)
        )
        let userProfileService: MockUserProfileService = MockUserProfileService()
        userProfileService.cachedUserProfileValue = cachedUserProfile
        let viewModel: UserProfileViewModel = UserProfileViewModel(userProfileService: userProfileService)

        viewModel.clearCachedUserProfile()

        XCTAssertEqual(userProfileService.clearCallCount, 1)
        XCTAssertEqual(viewModel.displayNameValue, "Not cached")
        XCTAssertEqual(viewModel.emailValue, "Not cached")
        XCTAssertEqual(viewModel.updatedAtValue, "Not cached")
        XCTAssertEqual(viewModel.statusMessage, "Removed cached user profile from the local database.")
    }

    private func formattedDateString(for date: Date) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}
