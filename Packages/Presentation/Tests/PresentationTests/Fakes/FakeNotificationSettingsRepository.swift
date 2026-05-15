import Domain

actor FakeNotificationSettingsRepository: NotificationSettingsRepository {
    var preferences: NotificationPreference = NotificationPreference()
    var saveCallCount = 0

    func setPreferences(_ value: NotificationPreference) {
        preferences = value
    }

    func fetchPreferences() async throws -> NotificationPreference { preferences }

    func savePreferences(_ value: NotificationPreference) async throws {
        preferences = value
        saveCallCount += 1
    }
}
