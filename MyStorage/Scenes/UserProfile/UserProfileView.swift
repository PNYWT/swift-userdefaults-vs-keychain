//
//  UserProfileView.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel

    let onSignOut: () -> Void
    let onShowOnboardingAgain: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("LocalDatabase + UserProfile")
                        .font(.largeTitle.bold())
                    Text("This scene simulates a protected profile flow: use secure credentials -> request profile -> cache it locally for offline access.")
                        .foregroundStyle(.secondary)
                }

                profileSection
                actionSection
                statusSection
            }
            .padding(24)
        }
    }

    private var profileSection: some View {
        cardSection {
            Text("Cached User Profile")
                .font(.headline)

            profileRow(title: "Display Name", value: viewModel.displayNameValue)
            profileRow(title: "Email", value: viewModel.emailValue)
            profileRow(title: "Updated At", value: viewModel.updatedAtValue)
        }
    }

    private var actionSection: some View {
        VStack(spacing: 12) {
            Button(action: handleRefreshUserProfileTapped) {
                Text(viewModel.isLoading ? "Refreshing Profile..." : "Fetch Protected Profile")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)

            Button(action: viewModel.loadCachedUserProfile) {
                Text("Load Cached Profile")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(role: .destructive, action: viewModel.clearCachedUserProfile) {
                Text("Clear Cached Profile")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(role: .destructive, action: onSignOut) {
                Text("Sign Out")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(action: onShowOnboardingAgain) {
                Text("Show Onboarding Again")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
    }

    private var statusSection: some View {
        cardSection(spacing: 8) {
            Text("Status")
                .font(.headline)
            Text(viewModel.statusMessage)
                .foregroundStyle(.secondary)
        }
    }

    private func handleRefreshUserProfileTapped() {
        Task {
            await viewModel.refreshUserProfile()
        }
    }

    private func profileRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(value)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private func cardSection<Content: View>(
        spacing: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: spacing) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    NavigationStack {
        UserProfileView(
            viewModel: UserProfileViewModel(),
            onSignOut: {},
            onShowOnboardingAgain: {}
        )
        .toolbar(.hidden, for: .navigationBar)
    }
}
