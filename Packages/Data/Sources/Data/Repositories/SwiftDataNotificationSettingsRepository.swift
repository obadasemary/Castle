import Foundation
import SwiftData
import Domain

@ModelActor
public actor SwiftDataNotificationSettingsRepository: NotificationSettingsRepository {
    public func fetchPreferences() async throws -> NotificationPreference {
        let descriptor = FetchDescriptor<NotificationSettingsModel>()
        if let model = try modelContext.fetch(descriptor).first {
            return NotificationSettingsMapper.toDomain(model)
        }
        let defaults = NotificationPreference()
        modelContext.insert(NotificationSettingsMapper.makeModel(from: defaults))
        try modelContext.save()
        return defaults
    }

    public func savePreferences(_ preferences: NotificationPreference) async throws {
        let descriptor = FetchDescriptor<NotificationSettingsModel>()
        if let existing = try modelContext.fetch(descriptor).first {
            NotificationSettingsMapper.apply(preferences, to: existing)
        } else {
            modelContext.insert(NotificationSettingsMapper.makeModel(from: preferences))
        }
        try modelContext.save()
    }
}
