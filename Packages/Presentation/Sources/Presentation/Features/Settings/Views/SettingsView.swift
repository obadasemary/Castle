import SwiftUI
import Domain

public struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    private let coordinator: AppCoordinator

    public init(
        coordinator: AppCoordinator,
        factory: any SettingsViewModelFactory
    ) {
        self.coordinator = coordinator
        _viewModel = State(initialValue: factory.makeSettingsViewModel())
    }

    public var body: some View {
        @Bindable var coordinator = coordinator
        NavigationStack(path: $coordinator.settingsPath) {
            content
                .navigationTitle("Settings")
                .task { await viewModel.load() }
        }
    }

    @ViewBuilder
    private var content: some View {
        @Bindable var viewModel = viewModel
        switch viewModel.state {
        case .idle, .loading:
            LoadingView(message: "Loading settings…")
        case .error(let message):
            ErrorView(message: message) {
                Task { await viewModel.load() }
            }
        case .loaded:
            Form {
                Section {
                    ProfileHeader(
                        displayName: $viewModel.displayName,
                        preferredCurrencyCode: viewModel.preferredCurrencyCode
                    )
                }
                GeneralSection(
                    preferredCurrencyCode: $viewModel.preferredCurrencyCode,
                    appearance: $viewModel.appearance,
                    monthlyBudgetAmount: $viewModel.monthlyBudgetAmount
                )
                NotificationsSection(
                    preferences: viewModel.preferences,
                    authStatus: viewModel.authStatus,
                    onToggle: { key in
                        Task { await viewModel.toggle(key) }
                    },
                    onLeadDaysChange: { days in
                        Task { await viewModel.setDefaultLeadDays(days) }
                    },
                    onEnableTap: {
                        Task { await viewModel.requestNotificationAuthorization() }
                    },
                    onOpenSettings: {
                        viewModel.openSystemSettings()
                    }
                )
            }
            .onChange(of: viewModel.displayName) { _, _ in
                Task { await viewModel.saveProfile() }
            }
            .onChange(of: viewModel.preferredCurrencyCode) { _, _ in
                Task { await viewModel.saveProfile() }
            }
            .onChange(of: viewModel.appearance) { _, _ in
                Task { await viewModel.saveProfile() }
            }
            .onChange(of: viewModel.monthlyBudgetAmount) { _, _ in
                Task { await viewModel.saveProfile() }
            }
        }
    }
}
