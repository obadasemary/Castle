import SwiftUI
import Core
import Domain

public struct DashboardView: View {
    @State private var viewModel: DashboardViewModel
    private let coordinator: AppCoordinator

    public init(
        coordinator: AppCoordinator,
        factory: any DashboardViewModelFactory
    ) {
        self.coordinator = coordinator
        _viewModel = State(initialValue: factory.makeDashboardViewModel())
    }

    public var body: some View {
        @Bindable var coordinator = coordinator
        NavigationStack(path: $coordinator.dashboardPath) {
            content
                .navigationTitle("Dashboard")
                .task { await viewModel.load() }
                .refreshable { await viewModel.load() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingView(message: "Loading dashboard…")
        case .error(let message):
            ErrorView(message: message) {
                Task { await viewModel.load() }
            }
        case .loaded(let summary):
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    HeroSpendCard(
                        monthlySpend: summary.monthlySpend,
                        trend: summary.trend,
                        formatter: CurrencyFormatter()
                    )
                    if let budget = summary.budgetProgress {
                        BudgetProgressView(progress: budget)
                    }
                    UpcomingPaymentsCarousel(
                        payments: summary.upcoming,
                        onSelect: { viewModel.showSubscription(id: $0) }
                    )
                    RecentActivityList(
                        events: summary.recentActivity,
                        onSelect: { viewModel.showSubscription(id: $0) }
                    )
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.lg)
            }
        }
    }
}
