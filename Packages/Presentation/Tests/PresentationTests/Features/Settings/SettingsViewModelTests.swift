import Foundation
import Testing
import Core
import Domain
@testable import Presentation

@Suite("SettingsViewModel")
@MainActor
struct SettingsViewModelTests {
    private func makeViewModel(
        profile: UserProfile? = nil,
        preferences: NotificationPreference = NotificationPreference(),
        authStatus: NotificationAuthorizationStatus = .notDetermined,
        grantOnRequest: Bool = true,
        router: FakeSettingsRouter? = nil
    ) async -> (SettingsViewModel, FakeUserProfileRepository, FakeNotificationSettingsRepository, FakeNotificationAuthorizationService) {
        let profileRepo = FakeUserProfileRepository()
        if let profile { await profileRepo.setProfile(profile) }
        let prefsRepo = FakeNotificationSettingsRepository()
        await prefsRepo.setPreferences(preferences)
        let authService = FakeNotificationAuthorizationService(status: authStatus, grantOnRequest: grantOnRequest)

        let vm = SettingsViewModel(
            userProfileRepository: profileRepo,
            notificationSettingsRepository: prefsRepo,
            toggleNotificationPreference: ToggleNotificationPreferenceUseCase(repository: prefsRepo),
            authorizationService: authService,
            router: router
        )
        return (vm, profileRepo, prefsRepo, authService)
    }

    @Test("load populates view model from repositories")
    func loadPopulates() async {
        let profile = UserProfile(
            displayName: "Adam",
            preferredCurrencyCode: "EUR",
            monthlyBudget: Money(amount: 100, currencyCode: "EUR"),
            appearance: .dark
        )
        let prefs = NotificationPreference(
            trialEndingReminders: false,
            priceIncreaseAlerts: true,
            monthlySummary: true,
            defaultReminderLeadDays: 5
        )
        let (vm, _, _, _) = await makeViewModel(
            profile: profile,
            preferences: prefs,
            authStatus: .authorized
        )

        await vm.load()

        #expect(vm.state == .loaded)
        #expect(vm.displayName == "Adam")
        #expect(vm.preferredCurrencyCode == "EUR")
        #expect(vm.appearance == .dark)
        #expect(vm.monthlyBudgetAmount == "100")
        #expect(vm.preferences == prefs)
        #expect(vm.authStatus == .authorized)
    }

    @Test("load with no profile uses defaults")
    func loadDefaults() async {
        let (vm, _, _, _) = await makeViewModel()
        await vm.load()
        #expect(vm.state == .loaded)
        #expect(vm.displayName.isEmpty)
        #expect(vm.preferredCurrencyCode == "USD")
        #expect(vm.appearance == .system)
        #expect(vm.monthlyBudgetAmount.isEmpty)
    }

    @Test("saveProfile persists current view-model state")
    func saveProfilePersists() async {
        let (vm, profileRepo, _, _) = await makeViewModel()
        await vm.load()

        vm.displayName = "Adam"
        vm.preferredCurrencyCode = "GBP"
        vm.appearance = .dark
        vm.monthlyBudgetAmount = "75.5"
        await vm.saveProfile()

        let saved = await profileRepo.profile
        #expect(saved?.displayName == "Adam")
        #expect(saved?.preferredCurrencyCode == "GBP")
        #expect(saved?.appearance == .dark)
        #expect(saved?.monthlyBudget == Money(amount: Decimal(string: "75.5")!, currencyCode: "GBP"))
    }

    @Test("saveProfile clears budget when amount is blank or zero")
    func saveProfileClearsBudget() async {
        let profile = UserProfile(
            displayName: "Adam",
            preferredCurrencyCode: "USD",
            monthlyBudget: Money(amount: 50, currencyCode: "USD"),
            appearance: .system
        )
        let (vm, profileRepo, _, _) = await makeViewModel(profile: profile)
        await vm.load()

        vm.monthlyBudgetAmount = ""
        await vm.saveProfile()

        let saved = await profileRepo.profile
        #expect(saved?.monthlyBudget == nil)
    }

    @Test("toggle updates a specific preference flag and persists")
    func toggleUpdatesPreference() async {
        let prefs = NotificationPreference(trialEndingReminders: true, priceIncreaseAlerts: false, monthlySummary: false)
        let (vm, _, prefsRepo, _) = await makeViewModel(preferences: prefs)
        await vm.load()

        await vm.toggle(.priceIncreaseAlerts)

        let stored = await prefsRepo.preferences
        #expect(stored.priceIncreaseAlerts == true)
        #expect(vm.preferences.priceIncreaseAlerts == true)
        #expect(vm.preferences.trialEndingReminders == true)
    }

    @Test("setDefaultLeadDays clamps to valid range and persists")
    func setDefaultLeadDaysClamps() async {
        let (vm, _, prefsRepo, _) = await makeViewModel()
        await vm.load()

        await vm.setDefaultLeadDays(99)

        let stored = await prefsRepo.preferences
        #expect(stored.defaultReminderLeadDays == SettingsViewModel.leadDayRange.upperBound)
        #expect(vm.preferences.defaultReminderLeadDays == SettingsViewModel.leadDayRange.upperBound)
    }

    @Test("requestNotificationAuthorization updates status after grant")
    func requestAuthorizationGrants() async {
        let (vm, _, _, authService) = await makeViewModel(authStatus: .notDetermined, grantOnRequest: true)
        await vm.load()
        #expect(vm.authStatus == .notDetermined)

        await vm.requestNotificationAuthorization()

        #expect(vm.authStatus == .authorized)
        #expect(await authService.requestCallCount == 1)
    }

    @Test("requestNotificationAuthorization reflects denial")
    func requestAuthorizationDenied() async {
        let (vm, _, _, _) = await makeViewModel(authStatus: .notDetermined, grantOnRequest: false)
        await vm.load()

        await vm.requestNotificationAuthorization()

        #expect(vm.authStatus == .denied)
    }

    @Test("supportedCurrencyCodes includes Middle-East currencies")
    func supportedCurrencyCodesIncludesMiddleEast() {
        let codes = SettingsViewModel.supportedCurrencyCodes
        let expected = ["SAR", "AED", "EGP", "TRY", "KWD", "QAR", "BHD", "OMR", "JOD"]
        for code in expected {
            #expect(codes.contains(code), "Missing currency: \(code)")
        }
    }

    @Test(
        "saveProfile and load round-trip with Middle-East currency",
        arguments: ["SAR", "AED", "EGP", "TRY", "KWD", "QAR", "BHD", "OMR", "JOD"]
    )
    func saveProfileRoundTripMiddleEastCurrency(code: String) async {
        let (vm, profileRepo, _, _) = await makeViewModel()
        await vm.load()

        vm.preferredCurrencyCode = code
        vm.monthlyBudgetAmount = "200"
        await vm.saveProfile()

        let saved = await profileRepo.profile
        #expect(saved?.preferredCurrencyCode == code)
        #expect(saved?.monthlyBudget == Money(amount: 200, currencyCode: code))
    }

    @Test("openSystemSettings forwards to router")
    func openSystemSettingsRoutes() async {
        let router = FakeSettingsRouter()
        let (vm, _, _, _) = await makeViewModel(router: router)
        vm.openSystemSettings()
        #expect(router.openSystemSettingsCallCount == 1)
    }
}
