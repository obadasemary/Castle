import Foundation
import SwiftData
import Domain

@ModelActor
public actor SwiftDataUserProfileRepository: UserProfileRepository {
    public func fetchProfile() async throws -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfileModel>()
        return try modelContext.fetch(descriptor).first.map(UserProfileMapper.toDomain)
    }

    public func saveProfile(_ profile: UserProfile) async throws {
        let targetID = profile.id
        let descriptor = FetchDescriptor<UserProfileModel>(
            predicate: #Predicate { $0.id == targetID }
        )
        if let existing = try modelContext.fetch(descriptor).first {
            UserProfileMapper.apply(profile, to: existing)
        } else {
            modelContext.insert(UserProfileMapper.makeModel(from: profile))
        }
        try modelContext.save()
    }
}
