import SwiftUI

public struct RootTabView: View {
    private let coordinator: AppCoordinator

    public init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        @Bindable var coordinator = coordinator
        TabView(selection: $coordinator.selectedTab) {
            DashboardPlaceholderView()
                .tabItem {
                    Label(AppTab.dashboard.title, systemImage: AppTab.dashboard.symbolName)
                }
                .tag(AppTab.dashboard)

            SubscriptionsPlaceholderView()
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
