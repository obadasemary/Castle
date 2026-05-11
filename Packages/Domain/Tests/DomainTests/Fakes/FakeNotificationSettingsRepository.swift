import Domain

final class FakeNotificationSettingsRepository: NotificationSettingsRepository, @unchecked Sendable {
    var preferences = NotificationPreference()
    var saveCallCount = 0

    func fetchPreferences() async throws -> NotificationPreference {
        preferences
    }

    func savePreferences(_ prefs: NotificationPreference) async throws {
        preferences = prefs
        saveCallCount += 1
    }
}
