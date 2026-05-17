import SwiftUI
import Core
import Domain

public struct AnalyticsView: View {
    @State private var viewModel: AnalyticsViewModel
    private let coordinator: AppCoordinator

    public init(
        coordinator: AppCoordinator,
        factory: any AnalyticsViewModelFactory
    ) {
        self.coordinator = coordinator
        _viewModel = State(initialValue: factory.makeAnalyticsViewModel())
    }

    public var body: some View {
        @Bindable var coordinator = coordinator
        NavigationStack(path: $coordinator.analyticsPath) {
            content
                .navigationTitle("Analytics")
                .task { await viewModel.load() }
                .refreshable { await viewModel.load() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingView(message: "Loading analytics…")
        case .error(let message):
            ErrorView(message: message) {
                Task { await viewModel.load() }
            }
        case .loaded(let summary) where summary.breakdown.isEmpty:
            EmptyStateView(
                symbolName: "chart.pie",
                title: "No data yet",
                message: "Add a few subscriptions and the charts will fill in here."
            )
        case .loaded(let summary):
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    InsightCard(insight: summary.insight)
                    section(title: "Spending by category") {
                        CategoryDonutChart(
                            breakdown: summary.breakdown,
                            totalLabel: CurrencyFormatter().string(from: summary.monthlySpend)
                        )
                    }
                    section(title: "Monthly trends") {
                        MonthlyTrendsChart(trend: summary.trend)
                    }
                    CategoryBreakdownList(breakdown: summary.breakdown)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.lg)
            }
        }
    }

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader(title)
            content()
                .padding(Spacing.md)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                        .fill(Color.castleSurfaceElevated)
                )
        }
    }
}
