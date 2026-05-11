public protocol UserProfileRepository: Sendable {
    func fetchProfile() async throws -> UserProfile?
    func saveProfile(_ profile: UserProfile) async throws
}
