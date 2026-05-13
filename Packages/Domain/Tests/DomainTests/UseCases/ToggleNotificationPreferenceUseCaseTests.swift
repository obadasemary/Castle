import Testing
@testable import Domain

@Suite("ToggleNotificationPreferenceUseCase")
struct ToggleNotificationPreferenceUseCaseTests {
    @Test("Toggling trialEndingReminders flips the value")
    func toggleTrialEndingReminders() async throws {
        let repo = FakeNotificationSettingsRepository()
        await repo.setPreferences(NotificationPreference(trialEndingReminders: true))

        let useCase = ToggleNotificationPreferenceUseCase(repository: repo)
        try await useCase.execute(key: .trialEndingReminders)

        #expect(await repo.preferences.trialEndingReminders == false)
        #expect(await repo.saveCallCount == 1)
    }

    @Test("Toggling twice restores original value")
    func toggleTwiceRestores() async throws {
        let repo = FakeNotificationSettingsRepository()
        await repo.setPreferences(NotificationPreference(priceIncreaseAlerts: false))

        let useCase = ToggleNotificationPreferenceUseCase(repository: repo)
        try await useCase.execute(key: .priceIncreaseAlerts)
        try await useCase.execute(key: .priceIncreaseAlerts)

        #expect(await repo.preferences.priceIncreaseAlerts == false)
        #expect(await repo.saveCallCount == 2)
    }
}
