import Domain

actor FakeNotificationSettingsRepository: NotificationSettingsRepository {
    var preferences = NotificationPreference()
    var saveCallCount = 0

    func setPreferences(_ new: NotificationPreference) {
        preferences = new
    }

    func fetchPreferences() async throws -> NotificationPreference {
        preferences
    }

    func savePreferences(_ prefs: NotificationPreference) async throws {
        preferences = prefs
        saveCallCount += 1
    }
}
