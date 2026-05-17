public protocol NotificationSettingsRepository: Sendable {
    func fetchPreferences() async throws -> NotificationPreference
    func savePreferences(_ preferences: NotificationPreference) async throws
}
