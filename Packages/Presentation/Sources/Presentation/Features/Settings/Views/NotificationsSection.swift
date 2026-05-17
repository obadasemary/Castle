import SwiftUI
import Domain

public struct NotificationsSection: View {
    private let preferences: NotificationPreference
    private let authStatus: NotificationAuthorizationStatus
    private let onToggle: (NotificationPreferenceKey) -> Void
    private let onLeadDaysChange: (Int) -> Void
    private let onEnableTap: () -> Void
    private let onOpenSettings: () -> Void

    public init(
        preferences: NotificationPreference,
        authStatus: NotificationAuthorizationStatus,
        onToggle: @escaping (NotificationPreferenceKey) -> Void,
        onLeadDaysChange: @escaping (Int) -> Void,
        onEnableTap: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) {
        self.preferences = preferences
        self.authStatus = authStatus
        self.onToggle = onToggle
        self.onLeadDaysChange = onLeadDaysChange
        self.onEnableTap = onEnableTap
        self.onOpenSettings = onOpenSettings
    }

    public var body: some View {
        Section {
            switch authStatus {
            case .denied:
                PermissionDeniedView(
                    permission: .notifications,
                    openSettings: onOpenSettings
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            case .notDetermined:
                Button {
                    onEnableTap()
                } label: {
                    Label("Enable notifications", systemImage: "bell.badge")
                }
            case .authorized, .provisional:
                EmptyView()
            }

            Toggle(isOn: bindingFor(.trialEndingReminders)) {
                Text("Trial ending reminders")
            }
            Toggle(isOn: bindingFor(.priceIncreaseAlerts)) {
                Text("Price increase alerts")
            }
            Toggle(isOn: bindingFor(.monthlySummary)) {
                Text("Monthly summary")
            }
            Stepper(
                value: leadDaysBinding,
                in: SettingsViewModel.leadDayRange
            ) {
                LabeledContent("Default reminder") {
                    Text(leadDaysLabel)
                        .foregroundStyle(Color.castleTextSecondary)
                }
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text("Reminders fire the chosen number of days before each renewal.")
        }
    }

    private func bindingFor(_ key: NotificationPreferenceKey) -> Binding<Bool> {
        Binding(
            get: { value(for: key) },
            set: { _ in onToggle(key) }
        )
    }

    private var leadDaysBinding: Binding<Int> {
        Binding(
            get: { preferences.defaultReminderLeadDays },
            set: { onLeadDaysChange($0) }
        )
    }

    private func value(for key: NotificationPreferenceKey) -> Bool {
        switch key {
        case .trialEndingReminders: preferences.trialEndingReminders
        case .priceIncreaseAlerts: preferences.priceIncreaseAlerts
        case .monthlySummary: preferences.monthlySummary
        }
    }

    private var leadDaysLabel: String {
        let days = preferences.defaultReminderLeadDays
        return days == 1 ? "1 day before" : "\(days) days before"
    }
}
