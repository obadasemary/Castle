public struct NotificationPreference: Hashable, Codable, Sendable {
    public var trialEndingReminders: Bool
    public var priceIncreaseAlerts: Bool
    public var monthlySummary: Bool
    public var defaultReminderLeadDays: Int

    public init(
        trialEndingReminders: Bool = true,
        priceIncreaseAlerts: Bool = true,
        monthlySummary: Bool = false,
        defaultReminderLeadDays: Int = 3
    ) {
        self.trialEndingReminders = trialEndingReminders
        self.priceIncreaseAlerts = priceIncreaseAlerts
        self.monthlySummary = monthlySummary
        self.defaultReminderLeadDays = defaultReminderLeadDays
    }
}
