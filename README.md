# swift-userdefaults-vs-keychain

Sample iOS SwiftUI project that compares `UserDefaults` and `Keychain` in a production-oriented MVVM structure with realistic models, reusable web services, and a local database flow for cached profile data.

## Overview

This project demonstrates:

- When to use `UserDefaults`
- When to use `Keychain`
- What kind of data belongs in a local database
- How to wire both into a SwiftUI MVVM app with `Scenes`, `Models`, `Services`, and `Storages`

The app has two clear flows:

- An onboarding flow backed by `UserDefaults`
- An auth flow backed by `Keychain` and a decoded authentication response
- A profile flow backed by `SwiftData` for cached protected user data

The repository also includes a realistic local database example for caching the authenticated user profile with `SwiftData`.

The active environment is controlled centrally through `AppConfig.current`.

## What Goes Where

### UserDefaults

Use `UserDefaults` for non-sensitive app state such as:

- onboarding completion
- feature flags
- theme selection
- simple preferences

In this project:

- `hasCompletedOnboarding` is stored in `UserDefaults`

### Keychain

Use `Keychain` for sensitive data such as:

- access tokens
- refresh tokens
- passwords
- API keys

In this project:

- `accessToken`
- `refreshToken`
- `userPassword`

are stored in `Keychain`.

### Local Database

Use a local database for structured offline or cached data such as:

- user profiles
- addresses
- order history
- carts
- orders
- any data you want to fetch once and reuse offline

In this project:

- `UserProfile` is the plain model
- `CachedUserProfile` is the `SwiftData` persistence model
- `LocalDatabase` is the wrapper around the local store

## Architecture

This project currently uses a production-oriented MVVM structure:

```text
View
-> ViewModel
-> Service / Manager
```

Examples:

- `AppRootView` -> `AppRootViewModel` -> `AppPreferencesService`
- `OnboardingView` -> `OnboardingViewModel` -> `AppPreferencesService` -> `UserDefaultsManager`
- `AuthView` -> `AuthViewModel` -> `AuthWebService` -> `WebService` -> decoded `LoginResponse`
- `AuthView` -> `AuthViewModel` -> `SecureStoreService` -> `KeychainManager`
- `UserProfileView` -> `UserProfileViewModel` -> `UserProfileService` -> `UserProfileWebService` + `LocalDatabase`

The goal is to keep the flow clear and practical for an article-backed sample:

- `View` renders UI
- `ViewModel` owns screen state and user actions
- `Models` describe request and response payloads
- `Services` hold app-level wrappers and web service abstractions
- `AppConfig` centralizes app environment and base URL selection
- `WebService` centralizes request building and decoding
- `SecureStoreService` is the sensitive-data bridge above Keychain
- `LocalDatabase` is the structured-data bridge above SwiftData
- storage managers handle persistence details

## Project Structure

```text
MyStorage
├── MyStorageApp.swift
├── Config
│   └── AppConfig.swift
├── Models
│   ├── Auth
│   │   ├── LoginRequest.swift
│   │   ├── LoginResponse.swift
│   │   └── AuthCredentials.swift
│   └── UserProfile
│       ├── CachedUserProfile.swift
│       ├── UserProfile.swift
│       └── UserProfileResponse.swift
├── Scenes
│   ├── Root
│   │   ├── AppRootView.swift
│   │   └── AppRootViewModel.swift
│   ├── Onboarding
│   │   ├── OnboardingView.swift
│   │   └── OnboardingViewModel.swift
│   ├── Auth
│       ├── AuthView.swift
│       └── AuthViewModel.swift
│   └── UserProfile
│       ├── UserProfileView.swift
│       └── UserProfileViewModel.swift
├── Services
│   ├── Preferences
│   │   ├── AppPreferencesService.swift
│   │   └── AppPreferencesServiceProtocol.swift
│   ├── LocalDatabaseService
│   │   ├── UserProfileService.swift
│   │   └── UserProfileServiceProtocol.swift
│   ├── SecureStore
│   │   ├── SecureStoreService.swift
│   │   └── SecureStoreServiceProtocol.swift
│   └── WebService
│       ├── Auth
│       │   └── AuthWebService.swift
│       ├── UserProfile
│       │   └── UserProfileWebService.swift
│       ├── WebService.swift
│       └── WebServiceError.swift
└── Storages
    ├── Keychain
    │   ├── KeychainConfiguration.swift
    │   ├── KeychainError.swift
    │   ├── KeychainManager.swift
    │   └── KeychainManagerProtocol.swift
    ├── LocalDatabase
    │   ├── LocalDatabase.swift
    │   └── LocalDatabaseProtocol.swift
    ├── UserDefaults
    │   ├── UserDefaultsManager.swift
    │   └── UserDefaultsManagerProtocol.swift
    └── StorageKeys.swift
```

## Important Files

- [AppConfig.swift](./MyStorage/Config/AppConfig.swift)
- [AppRootView.swift](./MyStorage/Scenes/Root/AppRootView.swift)
- [OnboardingViewModel.swift](./MyStorage/Scenes/Onboarding/OnboardingViewModel.swift)
- [AuthViewModel.swift](./MyStorage/Scenes/Auth/AuthViewModel.swift)
- [UserProfileViewModel.swift](./MyStorage/Scenes/UserProfile/UserProfileViewModel.swift)
- [LoginResponse.swift](./MyStorage/Models/Auth/LoginResponse.swift)
- [AuthCredentials.swift](./MyStorage/Models/Auth/AuthCredentials.swift)
- [UserProfile.swift](./MyStorage/Models/UserProfile/UserProfile.swift)
- [UserProfileResponse.swift](./MyStorage/Models/UserProfile/UserProfileResponse.swift)
- [CachedUserProfile.swift](./MyStorage/Models/UserProfile/CachedUserProfile.swift)
- [AppPreferencesService.swift](./MyStorage/Services/Preferences/AppPreferencesService.swift)
- [UserProfileService.swift](./MyStorage/Services/LocalDatabaseService/UserProfileService.swift)
- [SecureStoreService.swift](./MyStorage/Services/SecureStore/SecureStoreService.swift)
- [AuthWebService.swift](./MyStorage/Services/WebService/Auth/AuthWebService.swift)
- [UserProfileWebService.swift](./MyStorage/Services/WebService/UserProfile/UserProfileWebService.swift)
- [WebService.swift](./MyStorage/Services/WebService/WebService.swift)
- [LocalDatabase.swift](./MyStorage/Storages/LocalDatabase/LocalDatabase.swift)
- [UserDefaultsManager.swift](./MyStorage/Storages/UserDefaults/UserDefaultsManager.swift)
- [KeychainManager.swift](./MyStorage/Storages/Keychain/KeychainManager.swift)
- [StorageKeys.swift](./MyStorage/Storages/StorageKeys.swift)

## WebService Notes

The shared `WebService` layer in this project supports:

- app-config-based `baseURL`
- reusable endpoint definitions
- `GET` and `POST`
- query items and request bodies
- generic `Decodable` response handling
- real network transport for production

The default demo setup uses:

- `AppConfig.current`
- mock response generation inside `AuthWebService`
- request/response logging controlled by `AppConfig.shouldLogNetwork`
- sensitive values masked before printing, for example `abc********`

This keeps the structure close to production while still letting the example run without a real backend.

## Local Database Notes

The local database layer in this project uses `SwiftData` because it fits a modern SwiftUI app and is a good match for lightweight caching.

The current scaffold is intentionally simple:

- `UserProfile` is a plain Swift model that could come from a protected profile endpoint
- `CachedUserProfile` is the persisted `SwiftData` model
- `LocalDatabase` saves, fetches, and clears cached user profile records
- `UserProfileService` coordinates between `SecureStoreService`, `UserProfileWebService`, and `LocalDatabase`
- `UserProfileService` updates the cache only when the fetched profile changed
- `UserProfileService` falls back to cached data when the remote request fails and local data already exists

This keeps local persistence separate from:

- `UserDefaults` for simple app state
- `Keychain` for sensitive data

## Keychain Notes

The `KeychainManager` in this project supports:

- read `String`
- read `Data`
- save values
- update on duplicate item
- delete values

It uses:

- `kSecClassGenericPassword`
- `kSecAttrService`
- `kSecAttrAccount`
- `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`

The default service is currently:

```swift
static let keychainService: String = "com.companyname.appname"
```

Keep this value stable. Changing it later will make previously saved Keychain items unreadable by the app unless migration is handled.

## Running the Project

Open the Xcode project:

```text
MyStorage.xcodeproj
```

Or build from terminal:

```bash
xcodebuild -scheme MyStorage -project MyStorage.xcodeproj -configuration Debug -sdk iphonesimulator -derivedDataPath .xcodebuild CODE_SIGNING_ALLOWED=NO build
```

## Demo Flow

1. Launch the app
2. Complete onboarding
3. Enter email and password on the auth screen
4. Trigger login through `AuthWebService`
5. Decode `LoginResponse`
6. Save tokens and password into Keychain
7. Enter the user profile scene automatically after a successful login
8. Fetch protected profile data through `UserProfileWebService`
9. Cache that profile in `LocalDatabase`
10. Reload, clear, or sign out from the UI

## Notes

- This project is intentionally simple and focused on storage usage.
- It is suitable as a reference for learning when to choose `UserDefaults` vs `Keychain`.
- If the app grows, you can add more scenes while keeping the same `Scenes / Services / Storages` structure.
