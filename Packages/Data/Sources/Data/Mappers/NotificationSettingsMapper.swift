import Foundation
import Domain

enum NotificationSettingsMapper {
    static func toDomain(_ model: NotificationSettingsModel) -> NotificationPreference {
        NotificationPreference(
            trialEndingReminders: model.trialEndingReminders,
            priceIncreaseAlerts: model.priceIncreaseAlerts,
            monthlySummary: model.monthlySummary,
            defaultReminderLeadDays: model.defaultReminderLeadDays
        )
    }

    static func makeModel(from preferences: NotificationPreference) -> NotificationSettingsModel {
        NotificationSettingsModel(
            trialEndingReminders: preferences.trialEndingReminders,
            priceIncreaseAlerts: preferences.priceIncreaseAlerts,
            monthlySummary: preferences.monthlySummary,
            defaultReminderLeadDays: preferences.defaultReminderLeadDays
        )
    }

    static func apply(_ preferences: NotificationPreference, to model: NotificationSettingsModel) {
        model.trialEndingReminders = preferences.trialEndingReminders
        model.priceIncreaseAlerts = preferences.priceIncreaseAlerts
        model.monthlySummary = preferences.monthlySummary
        model.defaultReminderLeadDays = preferences.defaultReminderLeadDays
    }
}
