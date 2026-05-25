//
//  AuthView.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel

    let onLoginSuccess: () -> Void
    let onShowOnboardingAgain: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Keychain + WebService")
                        .font(.largeTitle.bold())
                    Text("This scene simulates a production-like login flow: request -> endpoint -> web service -> decode response -> persist credentials.")
                        .foregroundStyle(.secondary)
                }

                credentialInputSection
                storedCredentialSection
                actionSection
                statusSection
            }
            .padding(24)
        }
    }

    private var credentialInputSection: some View {
        cardSection {
            Text("Login Request")
                .font(.headline)

            TextField("Email", text: $viewModel.email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))

            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private var storedCredentialSection: some View {
        cardSection {
            Text("Stored Credentials")
                .font(.headline)

            credentialRow(title: "Access Token", value: viewModel.accessTokenValue)
            credentialRow(title: "Refresh Token", value: viewModel.refreshTokenValue)
            credentialRow(title: "Password", value: viewModel.userPasswordValue)
        }
    }

    private var actionSection: some View {
        VStack(spacing: 12) {
            Button(action: handleLoginTapped) {
                Text(viewModel.isLoading ? "Logging In..." : "Login with AuthWebService")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)

            Button(action: viewModel.loadStoredCredentials) {
                Text("Reload from Keychain")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(role: .destructive, action: viewModel.clearCredentials) {
                Text("Clear Credentials")
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

    private func handleLoginTapped() {
        Task {
            let didLoginSucceed: Bool = await viewModel.login()

            if didLoginSucceed {
                onLoginSuccess()
            }
        }
    }

    private func credentialRow(title: String, value: String) -> some View {
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
        AuthView(
            viewModel: AuthViewModel(),
            onLoginSuccess: {},
            onShowOnboardingAgain: {}
        )
        .toolbar(.hidden, for: .navigationBar)
    }
}
