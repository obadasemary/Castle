import Foundation
import SwiftData

@Model
final class NotificationSettingsModel {
    @Attribute(.unique) var id: UUID
    var trialEndingReminders: Bool
    var priceIncreaseAlerts: Bool
    var monthlySummary: Bool
    var defaultReminderLeadDays: Int

    init(
        id: UUID = NotificationSettingsModel.singletonID,
        trialEndingReminders: Bool,
        priceIncreaseAlerts: Bool,
        monthlySummary: Bool,
        defaultReminderLeadDays: Int
    ) {
        self.id = id
        self.trialEndingReminders = trialEndingReminders
        self.priceIncreaseAlerts = priceIncreaseAlerts
        self.monthlySummary = monthlySummary
        self.defaultReminderLeadDays = defaultReminderLeadDays
    }

    static let singletonID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
}
