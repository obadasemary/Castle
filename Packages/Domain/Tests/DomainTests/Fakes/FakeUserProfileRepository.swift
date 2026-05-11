import Domain

final class FakeUserProfileRepository: UserProfileRepository, @unchecked Sendable {
    var profile: UserProfile?
    var saveCallCount = 0

    func fetchProfile() async throws -> UserProfile? { profile }

    func saveProfile(_ p: UserProfile) async throws {
        profile = p
        saveCallCount += 1
    }
}
