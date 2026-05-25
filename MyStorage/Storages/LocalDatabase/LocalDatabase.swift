//
//  LocalDatabase.swift
//  MyStorage
//
//  Created by Punyawat on 25/5/2569 BE.
//

import Foundation
import SwiftData

@MainActor
final class LocalDatabase: LocalDatabaseProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
    }

    convenience init() {
        do {
            let configuration: ModelConfiguration = ModelConfiguration(
                AppStorageConfiguration.localDatabaseName
            )
            let modelContainer: ModelContainer = try ModelContainer(
                for: CachedUserProfile.self,
                configurations: configuration
            )

            self.init(modelContainer: modelContainer)
        } catch {
            fatalError("Failed to initialize LocalDatabase: \(error)")
        }
    }

    func cachedUserProfile() throws -> CachedUserProfile? {
        let descriptor: FetchDescriptor<CachedUserProfile> = FetchDescriptor(
            sortBy: [SortDescriptor(\CachedUserProfile.updatedAt, order: .reverse)]
        )

        let cachedUserProfiles: [CachedUserProfile] = try modelContext.fetch(descriptor)
        return cachedUserProfiles.first
    }

    func saveUserProfile(_ userProfile: UserProfile) throws {
        try clearUserProfile()

        let cachedUserProfile: CachedUserProfile = CachedUserProfile(userProfile: userProfile)
        modelContext.insert(cachedUserProfile)

        try modelContext.save()
    }

    func clearUserProfile() throws {
        let descriptor: FetchDescriptor<CachedUserProfile> = FetchDescriptor()
        let existingUserProfiles: [CachedUserProfile] = try modelContext.fetch(descriptor)

        for existingUserProfile in existingUserProfiles {
            modelContext.delete(existingUserProfile)
        }

        try modelContext.save()
    }
}
