//
//  AppRootView.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import SwiftUI

struct AppRootView: View {
    @StateObject private var viewModel: AppRootViewModel

    init() {
        let viewModel: AppRootViewModel = AppRootViewModel()
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            switch viewModel.route {
            case .onboarding:
                OnboardingView(
                    viewModel: OnboardingViewModel(),
                    onContinue: {
                        viewModel.refreshRoute()
                    }
                )
                .toolbar(.hidden, for: .navigationBar)
            case .auth:
                AuthView(
                    viewModel: AuthViewModel(),
                    onLoginSuccess: {
                        viewModel.showUserProfile()
                    },
                    onShowOnboardingAgain: {
                        viewModel.showOnboarding()
                    }
                )
                .toolbar(.hidden, for: .navigationBar)
            case .userProfile:
                UserProfileView(
                    viewModel: UserProfileViewModel(),
                    onSignOut: {
                        viewModel.signOut()
                    },
                    onShowOnboardingAgain: {
                        viewModel.showOnboarding()
                    }
                )
                .toolbar(.hidden, for: .navigationBar)
            }
        }
    }
}

#Preview {
    AppRootView()
}
