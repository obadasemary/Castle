public enum NotificationPreferenceKey: Hashable, Sendable {
    case trialEndingReminders
    case priceIncreaseAlerts
    case monthlySummary
}

public struct ToggleNotificationPreferenceUseCase: Sendable {
    private let repository: any NotificationSettingsRepository

    public init(repository: any NotificationSettingsRepository) {
        self.repository = repository
    }

    public func execute(key: NotificationPreferenceKey) async throws {
        var prefs = try await repository.fetchPreferences()
        switch key {
        case .trialEndingReminders: prefs.trialEndingReminders.toggle()
        case .priceIncreaseAlerts:  prefs.priceIncreaseAlerts.toggle()
        case .monthlySummary:       prefs.monthlySummary.toggle()
        }
        try await repository.savePreferences(prefs)
    }
}
