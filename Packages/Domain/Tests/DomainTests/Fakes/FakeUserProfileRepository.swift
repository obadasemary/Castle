import Domain

actor FakeUserProfileRepository: UserProfileRepository {
    var profile: UserProfile?
    var saveCallCount = 0

    func setProfile(_ p: UserProfile?) {
        profile = p
    }

    func fetchProfile() async throws -> UserProfile? { profile }

    func saveProfile(_ p: UserProfile) async throws {
        profile = p
        saveCallCount += 1
    }
}
