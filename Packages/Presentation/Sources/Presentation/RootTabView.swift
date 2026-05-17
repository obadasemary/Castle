import SwiftUI

public struct RootTabView: View {
    private let coordinator: AppCoordinator
    @Environment(\.subscriptionsViewModelFactory) private var subscriptionsFactory
    @Environment(\.dashboardViewModelFactory) private var dashboardFactory
    @Environment(\.analyticsViewModelFactory) private var analyticsFactory
    @Environment(\.settingsViewModelFactory) private var settingsFactory

    public init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        @Bindable var coordinator = coordinator
        TabView(selection: $coordinator.selectedTab) {
            Group {
                if let dashboardFactory {
                    DashboardView(coordinator: coordinator, factory: dashboardFactory)
                } else {
                    DashboardPlaceholderView()
                }
            }
            .tabItem {
                Label(AppTab.dashboard.title, systemImage: AppTab.dashboard.symbolName)
            }
            .tag(AppTab.dashboard)

            Group {
                if let subscriptionsFactory {
                    SubscriptionsListView(coordinator: coordinator, factory: subscriptionsFactory)
                } else {
                    SubscriptionsPlaceholderView()
                }
            }
            .tabItem {
                Label(AppTab.subscriptions.title, systemImage: AppTab.subscriptions.symbolName)
            }
            .tag(AppTab.subscriptions)

            Group {
                if let analyticsFactory {
                    AnalyticsView(coordinator: coordinator, factory: analyticsFactory)
                } else {
                    AnalyticsPlaceholderView()
                }
            }
            .tabItem {
                Label(AppTab.analytics.title, systemImage: AppTab.analytics.symbolName)
            }
            .tag(AppTab.analytics)

            Group {
                if let settingsFactory {
                    SettingsView(coordinator: coordinator, factory: settingsFactory)
                } else {
                    SettingsPlaceholderView()
                }
            }
            .tabItem {
                Label(AppTab.settings.title, systemImage: AppTab.settings.symbolName)
            }
            .tag(AppTab.settings)
        }
        .tint(Color.castleAccentBrand)
    }
}

#Preview {
    RootTabView(coordinator: AppCoordinator())
}
