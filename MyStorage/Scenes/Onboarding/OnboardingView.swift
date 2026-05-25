//
//  OnboardingView.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.titleText)
                        .font(.largeTitle.bold())
                    Text(viewModel.subtitleText)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 16) {
                    onboardingItem(
                        title: "What is stored here?",
                        description: "`hasCompletedOnboarding` is persisted through AppPreferencesService and UserDefaultsManager."
                    )
                    onboardingItem(
                        title: "Why UserDefaults?",
                        description: "This is simple app state, not secret data."
                    )
                }

                Button(action: handleContinueTapped) {
                    Text("Complete Onboarding")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
        }
    }

    private func handleContinueTapped() {
        viewModel.completeOnboarding()
        onContinue()
    }

    private func onboardingItem(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(description)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    NavigationStack {
        OnboardingView(
            viewModel: OnboardingViewModel(),
            onContinue: {}
        )
        .toolbar(.hidden, for: .navigationBar)
    }
}
