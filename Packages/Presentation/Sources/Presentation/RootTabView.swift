import SwiftUI

public struct RootTabView: View {
    private let coordinator: AppCoordinator
    @Environment(\.subscriptionsViewModelFactory) private var subscriptionsFactory
    @Environment(\.dashboardViewModelFactory) private var dashboardFactory

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

            AnalyticsPlaceholderView()
                .tabItem {
                    Label(AppTab.analytics.title, systemImage: AppTab.analytics.symbolName)
                }
                .tag(AppTab.analytics)

            SettingsPlaceholderView()
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
