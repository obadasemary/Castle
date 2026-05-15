import Foundation
import Testing
import Core
import Domain
@testable import Presentation

@Suite("AnalyticsViewModel")
@MainActor
struct AnalyticsViewModelTests {
    private func makeViewModel(
        subscriptions: [Subscription] = [],
        payments: [PaymentRecord] = [],
        profile: UserProfile? = nil,
        clockNow: Date = Date(timeIntervalSince1970: 1_700_000_000),
        router: FakeAnalyticsRouter? = nil
    ) async -> AnalyticsViewModel {
        let subscriptionRepo = FakeSubscriptionRepository()
        for sub in subscriptions { await subscriptionRepo.seed(sub) }
        let paymentRepo = FakePaymentRepository()
        for payment in payments { await paymentRepo.seed(payment) }
        let profileRepo = FakeUserProfileRepository()
        if let profile { await profileRepo.setProfile(profile) }
        let clock = FakeClock(now: clockNow)
        let calendar = FakeCalendarProvider()

        return AnalyticsViewModel(
            userProfileRepository: profileRepo,
            buildBreakdown: BuildCategoryBreakdownUseCase(repository: subscriptionRepo),
            buildTrend: BuildSpendingTrendUseCase(
                paymentRepository: paymentRepo,
                clock: clock,
                calendarProvider: calendar
            ),
            calculateMonthlySpend: CalculateMonthlySpendUseCase(repository: subscriptionRepo),
            router: router
        )
    }

    private func subscription(
        name: String,
        category: Domain.Category,
        amount: Decimal,
        status: Subscription.Status = .active
    ) -> Subscription {
        Subscription(
            serviceName: name,
            category: category,
            price: Money(amount: amount, currencyCode: "USD"),
            billingCycle: .monthly,
            nextBillingDate: Date(timeIntervalSince1970: 1_700_000_000 + 7 * 86_400),
            status: status
        )
    }

    @Test("starts idle")
    func startsIdle() async {
        let vm = await makeViewModel()
        #expect(vm.state == .idle)
    }

    @Test("load builds category breakdown sorted by spend desc")
    func loadBuildsBreakdown() async {
        let netflix = subscription(name: "Netflix", category: .entertainment, amount: 15.99)
        let claude = subscription(name: "Claude", category: .ai, amount: 20)
        let spotify = subscription(name: "Spotify", category: .music, amount: 9.99)
        let vm = await makeViewModel(subscriptions: [netflix, claude, spotify])

        await vm.load()

        guard case .loaded(let summary) = vm.state else {
            Issue.record("expected loaded; got \(vm.state)")
            return
        }
        #expect(summary.breakdown.map(\.category) == [.ai, .entertainment, .music])
        #expect(summary.monthlySpend.amount == Decimal(string: "45.98"))
        #expect(summary.breakdown.count == 3)
    }

    @Test("load returns empty breakdown when no active subscriptions")
    func loadEmptyBreakdown() async {
        let vm = await makeViewModel()
        await vm.load()
        guard case .loaded(let summary) = vm.state else {
            Issue.record("expected loaded; got \(vm.state)")
            return
        }
        #expect(summary.breakdown.isEmpty)
        #expect(summary.insight == "Add a subscription to start tracking your spending.")
    }

    @Test("insight prefers month-over-month delta when significant")
    func insightMonthOverMonth() {
        let breakdown = [
            CategorySpend(category: .ai, total: Money(amount: 50, currencyCode: "USD"), percentage: 100)
        ]
        let trend = [
            MonthlySpend(year: 2026, month: 1, total: Money(amount: 10, currencyCode: "USD")),
            MonthlySpend(year: 2026, month: 2, total: Money(amount: 20, currencyCode: "USD"))
        ]
        let result = AnalyticsViewModel.buildInsight(breakdown: breakdown, trend: trend)
        #expect(result == "Spending is up 100% vs last month.")
    }

    @Test("insight reports decrease when spending dropped")
    func insightDecrease() {
        let breakdown = [
            CategorySpend(category: .ai, total: Money(amount: 10, currencyCode: "USD"), percentage: 100)
        ]
        let trend = [
            MonthlySpend(year: 2026, month: 1, total: Money(amount: 100, currencyCode: "USD")),
            MonthlySpend(year: 2026, month: 2, total: Money(amount: 80, currencyCode: "USD"))
        ]
        let result = AnalyticsViewModel.buildInsight(breakdown: breakdown, trend: trend)
        #expect(result == "Nice — spending dropped 20% vs last month.")
    }

    @Test("insight falls back to dominant category when month delta is small")
    func insightDominantCategory() {
        let breakdown = [
            CategorySpend(category: .entertainment, total: Money(amount: 60, currencyCode: "USD"), percentage: 60),
            CategorySpend(category: .ai, total: Money(amount: 40, currencyCode: "USD"), percentage: 40)
        ]
        let trend = [
            MonthlySpend(year: 2026, month: 1, total: Money(amount: 100, currencyCode: "USD")),
            MonthlySpend(year: 2026, month: 2, total: Money(amount: 100, currencyCode: "USD"))
        ]
        let result = AnalyticsViewModel.buildInsight(breakdown: breakdown, trend: trend)
        #expect(result == "60% of your monthly spend goes to Entertainment.")
    }

    @Test("insight falls back to category count when nothing dominant")
    func insightCategoryCount() {
        let breakdown = [
            CategorySpend(category: .ai, total: Money(amount: 10, currencyCode: "USD"), percentage: 25),
            CategorySpend(category: .entertainment, total: Money(amount: 10, currencyCode: "USD"), percentage: 25),
            CategorySpend(category: .music, total: Money(amount: 10, currencyCode: "USD"), percentage: 25),
            CategorySpend(category: .productivity, total: Money(amount: 10, currencyCode: "USD"), percentage: 25)
        ]
        let result = AnalyticsViewModel.buildInsight(breakdown: breakdown, trend: [])
        #expect(result == "Your subscriptions span 4 categories.")
    }

    @Test("showCategoryDetail forwards to router")
    func showCategoryDetailRoutes() async {
        let router = FakeAnalyticsRouter()
        let vm = await makeViewModel(router: router)
        vm.showCategoryDetail(.ai)
        #expect(router.showCategoryDetailCalls == [.ai])
    }
}
