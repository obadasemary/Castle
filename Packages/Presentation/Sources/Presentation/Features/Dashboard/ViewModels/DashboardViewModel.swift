import Foundation
import Observation
import Core
import Domain

@Observable
@MainActor
public final class DashboardViewModel {
    public struct Summary: Sendable, Equatable {
        public let currencyCode: String
        public let monthlySpend: Money
        public let trend: [MonthlySpend]
        public let budgetProgress: BudgetProgress?
        public let upcoming: [Subscription]
        public let recentActivity: [ActivityEvent]
    }

    public enum State: Sendable, Equatable {
        case idle
        case loading
        case loaded(Summary)
        case error(String)
    }

    public var state: State = .idle

    private let userProfileRepository: any UserProfileRepository
    private let calculateMonthlySpend: CalculateMonthlySpendUseCase
    private let buildSpendingTrend: BuildSpendingTrendUseCase
    private let calculateBudgetProgress: CalculateBudgetProgressUseCase
    private let fetchUpcoming: FetchUpcomingPaymentsUseCase
    private let fetchRecentActivity: FetchRecentActivityUseCase
    private weak var router: (any DashboardRouter)?

    public init(
        userProfileRepository: any UserProfileRepository,
        calculateMonthlySpend: CalculateMonthlySpendUseCase,
        buildSpendingTrend: BuildSpendingTrendUseCase,
        calculateBudgetProgress: CalculateBudgetProgressUseCase,
        fetchUpcoming: FetchUpcomingPaymentsUseCase,
        fetchRecentActivity: FetchRecentActivityUseCase,
        router: (any DashboardRouter)? = nil
    ) {
        self.userProfileRepository = userProfileRepository
        self.calculateMonthlySpend = calculateMonthlySpend
        self.buildSpendingTrend = buildSpendingTrend
        self.calculateBudgetProgress = calculateBudgetProgress
        self.fetchUpcoming = fetchUpcoming
        self.fetchRecentActivity = fetchRecentActivity
        self.router = router
    }

    public func load() async {
        state = .loading
        do {
            let profile = try await userProfileRepository.fetchProfile()
            let currencyCode = profile?.preferredCurrencyCode ?? "USD"

            async let monthly = calculateMonthlySpend.execute(currencyCode: currencyCode)
            async let trend = buildSpendingTrend.execute(currencyCode: currencyCode, months: 6)
            async let budget = calculateBudgetProgress.execute(currencyCode: currencyCode)
            async let upcoming = fetchUpcoming.execute(withinDays: 30)
            async let activity = fetchRecentActivity.execute(limit: 10)

            let summary = Summary(
                currencyCode: currencyCode,
                monthlySpend: try await monthly,
                trend: try await trend,
                budgetProgress: try await budget,
                upcoming: try await upcoming,
                recentActivity: try await activity
            )
            state = .loaded(summary)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    public func showSubscription(id: UUID) {
        router?.showSubscriptionDetail(id)
    }

    public func showAllSubscriptions() {
        router?.showSubscriptions()
    }
}
