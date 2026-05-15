import Foundation
import Observation
import Core
import Domain

@Observable
@MainActor
public final class SettingsViewModel {
    public enum State: Sendable, Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }

    public static let supportedCurrencyCodes = [
        "USD", "EUR", "GBP", "JPY", "CAD", "AUD", "INR",
        "SAR", "AED", "EGP", "TRY", "KWD", "QAR", "BHD", "OMR", "JOD"
    ]
    public static let leadDayRange = 0...14

    public var state: State = .idle
    public var displayName: String = ""
    public var preferredCurrencyCode: String = "USD"
    public var appearance: UserProfile.Appearance = .system
    public var monthlyBudgetAmount: String = ""
    public var preferences: NotificationPreference = NotificationPreference()
    public var authStatus: NotificationAuthorizationStatus = .notDetermined

    private var loadedProfile: UserProfile?

    private let userProfileRepository: any UserProfileRepository
    private let notificationSettingsRepository: any NotificationSettingsRepository
    private let toggleNotificationPreference: ToggleNotificationPreferenceUseCase
    private let authorizationService: any NotificationAuthorizationService
    private weak var router: (any SettingsRouter)?

    public init(
        userProfileRepository: any UserProfileRepository,
        notificationSettingsRepository: any NotificationSettingsRepository,
        toggleNotificationPreference: ToggleNotificationPreferenceUseCase,
        authorizationService: any NotificationAuthorizationService,
        router: (any SettingsRouter)? = nil
    ) {
        self.userProfileRepository = userProfileRepository
        self.notificationSettingsRepository = notificationSettingsRepository
        self.toggleNotificationPreference = toggleNotificationPreference
        self.authorizationService = authorizationService
        self.router = router
    }

    public func load() async {
        state = .loading
        do {
            let profile = try await userProfileRepository.fetchProfile() ?? UserProfile()
            loadedProfile = profile
            displayName = profile.displayName
            preferredCurrencyCode = profile.preferredCurrencyCode
            appearance = profile.appearance
            monthlyBudgetAmount = profile.monthlyBudget.map { Self.format(amount: $0.amount) } ?? ""
            preferences = try await notificationSettingsRepository.fetchPreferences()
            authStatus = await authorizationService.currentStatus()
            state = .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    public func saveProfile() async {
        let trimmedAmount = monthlyBudgetAmount.trimmingCharacters(in: .whitespaces)
        let budget: Money?
        if !trimmedAmount.isEmpty, let amount = Decimal(string: trimmedAmount), amount > 0 {
            budget = Money(amount: amount, currencyCode: preferredCurrencyCode)
        } else {
            budget = nil
        }
        let profile = UserProfile(
            id: loadedProfile?.id ?? UUID(),
            displayName: displayName,
            preferredCurrencyCode: preferredCurrencyCode,
            monthlyBudget: budget,
            appearance: appearance
        )
        do {
            try await userProfileRepository.saveProfile(profile)
            loadedProfile = profile
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    public func toggle(_ key: NotificationPreferenceKey) async {
        do {
            try await toggleNotificationPreference.execute(key: key)
            preferences = try await notificationSettingsRepository.fetchPreferences()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    public func setDefaultLeadDays(_ days: Int) async {
        let clamped = min(max(days, Self.leadDayRange.lowerBound), Self.leadDayRange.upperBound)
        var prefs = preferences
        prefs.defaultReminderLeadDays = clamped
        do {
            try await notificationSettingsRepository.savePreferences(prefs)
            preferences = prefs
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    public func requestNotificationAuthorization() async {
        do {
            _ = try await authorizationService.requestAuthorization()
            authStatus = await authorizationService.currentStatus()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    public func refreshAuthorizationStatus() async {
        authStatus = await authorizationService.currentStatus()
    }

    public func openSystemSettings() {
        router?.openSystemSettings()
    }

    private static func format(amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = false
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }
}
