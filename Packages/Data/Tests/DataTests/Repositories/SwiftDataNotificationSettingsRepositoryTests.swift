import Testing
import Foundation
import Domain
@testable import Data

@Suite("SwiftDataNotificationSettingsRepository")
struct SwiftDataNotificationSettingsRepositoryTests {
    @Test("fetchPreferences seeds defaults on first call")
    func fetchPreferencesSeedsDefaults() async throws {
        let container = try ModelContainerFactory.inMemory()
        let repo = SwiftDataNotificationSettingsRepository(modelContainer: container)

        let preferences = try await repo.fetchPreferences()

        #expect(preferences == NotificationPreference())
    }

    @Test("savePreferences then fetchPreferences round-trips the saved values")
    func savePreferencesRoundTrip() async throws {
        let container = try ModelContainerFactory.inMemory()
        let repo = SwiftDataNotificationSettingsRepository(modelContainer: container)
        let updated = NotificationPreference(
            trialEndingReminders: false,
            priceIncreaseAlerts: false,
            monthlySummary: true,
            defaultReminderLeadDays: 7
        )

        try await repo.savePreferences(updated)
        let fetched = try await repo.fetchPreferences()

        #expect(fetched == updated)
    }

    @Test("savePreferences is idempotent and updates the single row")
    func savePreferencesUpdatesExisting() async throws {
        let container = try ModelContainerFactory.inMemory()
        let repo = SwiftDataNotificationSettingsRepository(modelContainer: container)

        try await repo.savePreferences(NotificationPreference(trialEndingReminders: false))
        try await repo.savePreferences(NotificationPreference(monthlySummary: true))

        let fetched = try await repo.fetchPreferences()
        #expect(fetched.trialEndingReminders == true)
        #expect(fetched.monthlySummary == true)
    }
}
