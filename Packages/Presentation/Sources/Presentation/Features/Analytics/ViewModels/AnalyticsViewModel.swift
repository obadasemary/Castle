import Foundation
import Observation
import Core
import Domain

@Observable
@MainActor
public final class AnalyticsViewModel {
    public struct Summary: Sendable, Equatable {
        public let currencyCode: String
        public let monthlySpend: Money
        public let breakdown: [CategorySpend]
        public let trend: [MonthlySpend]
        public let insight: String
    }

    public enum State: Sendable, Equatable {
        case idle
        case loading
        case loaded(Summary)
        case error(String)
    }

    public var state: State = .idle

    private let userProfileRepository: any UserProfileRepository
    private let buildBreakdown: BuildCategoryBreakdownUseCase
    private let buildTrend: BuildSpendingTrendUseCase
    private let calculateMonthlySpend: CalculateMonthlySpendUseCase
    private weak var router: (any AnalyticsRouter)?

    public init(
        userProfileRepository: any UserProfileRepository,
        buildBreakdown: BuildCategoryBreakdownUseCase,
        buildTrend: BuildSpendingTrendUseCase,
        calculateMonthlySpend: CalculateMonthlySpendUseCase,
        router: (any AnalyticsRouter)? = nil
    ) {
        self.userProfileRepository = userProfileRepository
        self.buildBreakdown = buildBreakdown
        self.buildTrend = buildTrend
        self.calculateMonthlySpend = calculateMonthlySpend
        self.router = router
    }

    public func load() async {
        state = .loading
        do {
            let profile = try await userProfileRepository.fetchProfile()
            let currencyCode = profile?.preferredCurrencyCode ?? "USD"

            async let breakdown = buildBreakdown.execute(currencyCode: currencyCode)
            async let trend = buildTrend.execute(currencyCode: currencyCode, months: 6)
            async let monthly = calculateMonthlySpend.execute(currencyCode: currencyCode)

            let resolvedBreakdown = try await breakdown
            let resolvedTrend = try await trend
            let summary = Summary(
                currencyCode: currencyCode,
                monthlySpend: try await monthly,
                breakdown: resolvedBreakdown,
                trend: resolvedTrend,
                insight: Self.buildInsight(breakdown: resolvedBreakdown, trend: resolvedTrend)
            )
            state = .loaded(summary)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    public func showCategoryDetail(_ category: Domain.Category) {
        router?.showCategoryDetail(category)
    }

    static func buildInsight(breakdown: [CategorySpend], trend: [MonthlySpend]) -> String {
        if breakdown.isEmpty {
            return "Add a subscription to start tracking your spending."
        }

        if trend.count >= 2 {
            let current = trend[trend.count - 1].total.amount
            let prior = trend[trend.count - 2].total.amount
            if prior > 0 {
                let delta = current - prior
                let pctDecimal = (delta / prior) * 100
                let pct = Int((pctDecimal as NSDecimalNumber).doubleValue.rounded())
                if pct >= 5 {
                    return "Spending is up \(pct)% vs last month."
                } else if pct <= -5 {
                    return "Nice — spending dropped \(-pct)% vs last month."
                }
            }
        }

        if let top = breakdown.first, top.percentage >= 50 {
            return "\(Int(top.percentage.rounded()))% of your monthly spend goes to \(top.category.displayName)."
        }

        let count = breakdown.count
        return count == 1
            ? "Your subscriptions span 1 category."
            : "Your subscriptions span \(count) categories."
    }
}
