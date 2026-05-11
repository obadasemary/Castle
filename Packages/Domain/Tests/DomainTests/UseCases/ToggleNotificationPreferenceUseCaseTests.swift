import Testing
@testable import Domain

@Suite("ToggleNotificationPreferenceUseCase")
struct ToggleNotificationPreferenceUseCaseTests {
    @Test("Toggling trialEndingReminders flips the value")
    func toggleTrialEndingReminders() async throws {
        let repo = FakeNotificationSettingsRepository()
        repo.preferences.trialEndingReminders = true

        let useCase = ToggleNotificationPreferenceUseCase(repository: repo)
        try await useCase.execute(key: .trialEndingReminders)

        #expect(repo.preferences.trialEndingReminders == false)
        #expect(repo.saveCallCount == 1)
    }

    @Test("Toggling twice restores original value")
    func toggleTwiceRestores() async throws {
        let repo = FakeNotificationSettingsRepository()
        repo.preferences.priceIncreaseAlerts = false

        let useCase = ToggleNotificationPreferenceUseCase(repository: repo)
        try await useCase.execute(key: .priceIncreaseAlerts)
        try await useCase.execute(key: .priceIncreaseAlerts)

        #expect(repo.preferences.priceIncreaseAlerts == false)
        #expect(repo.saveCallCount == 2)
    }
}
