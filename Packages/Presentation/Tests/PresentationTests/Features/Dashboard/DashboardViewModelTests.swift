import Foundation
import Testing
import Core
import Domain
@testable import Presentation

@Suite("DashboardViewModel")
@MainActor
struct DashboardViewModelTests {
    private func makeViewModel(
        subscriptions: [Subscription] = [],
        payments: [PaymentRecord] = [],
        profile: UserProfile? = nil,
        clockNow: Date = Date(timeIntervalSince1970: 1_700_000_000),
        router: FakeDashboardRouter? = nil
    ) async -> (DashboardViewModel, FakeSubscriptionRepository, FakePaymentRepository, FakeUserProfileRepository) {
        let subscriptionRepo = FakeSubscriptionRepository()
        for sub in subscriptions { await subscriptionRepo.seed(sub) }
        let paymentRepo = FakePaymentRepository()
        for payment in payments { await paymentRepo.seed(payment) }
        let profileRepo = FakeUserProfileRepository()
        if let profile { await profileRepo.setProfile(profile) }
        let clock = FakeClock(now: clockNow)
        let calendar = FakeCalendarProvider()

        let vm = DashboardViewModel(
            userProfileRepository: profileRepo,
            calculateMonthlySpend: CalculateMonthlySpendUseCase(repository: subscriptionRepo),
            buildSpendingTrend: BuildSpendingTrendUseCase(
                paymentRepository: paymentRepo,
                clock: clock,
                calendarProvider: calendar
            ),
            calculateBudgetProgress: CalculateBudgetProgressUseCase(
                subscriptionRepository: subscriptionRepo,
                userProfileRepository: profileRepo
            ),
            fetchUpcoming: FetchUpcomingPaymentsUseCase(
                repository: subscriptionRepo,
                clock: clock,
                calendarProvider: calendar
            ),
            fetchRecentActivity: FetchRecentActivityUseCase(paymentRepository: paymentRepo),
            router: router
        )
        return (vm, subscriptionRepo, paymentRepo, profileRepo)
    }

    private func subscription(
        name: String,
        amount: Decimal = 9.99,
        cycle: BillingCycle = .monthly,
        status: Subscription.Status = .active,
        daysFromNow: Int = 7,
        clockNow: Date = Date(timeIntervalSince1970: 1_700_000_000)
    ) -> Subscription {
        Subscription(
            serviceName: name,
            category: .entertainment,
            price: Money(amount: amount, currencyCode: "USD"),
            billingCycle: cycle,
            nextBillingDate: clockNow.addingTimeInterval(TimeInterval(daysFromNow) * 86_400),
            status: status
        )
    }

    @Test("starts in idle state")
    func startsIdle() async {
        let (vm, _, _, _) = await makeViewModel()
        #expect(vm.state == .idle)
    }

    @Test("load builds summary with monthly spend in active currency")
    func loadBuildsSummary() async {
        let netflix = subscription(name: "Netflix", amount: 15.99)
        let spotify = subscription(name: "Spotify", amount: 10.99, daysFromNow: 14)
        let archived = subscription(name: "Old", amount: 5.99, status: .archived, daysFromNow: 5)
        let profile = UserProfile(
            displayName: "User",
            preferredCurrencyCode: "USD",
            monthlyBudget: Money(amount: 50, currencyCode: "USD")
        )
        let (vm, _, _, _) = await makeViewModel(
            subscriptions: [netflix, spotify, archived],
            profile: profile
        )

        await vm.load()

        guard case .loaded(let summary) = vm.state else {
            Issue.record("expected loaded; got \(vm.state)")
            return
        }
        #expect(summary.currencyCode == "USD")
        #expect(summary.monthlySpend.currencyCode == "USD")
        #expect(summary.monthlySpend.amount == Decimal(string: "26.98"))
        #expect(summary.upcoming.map(\.serviceName) == ["Netflix", "Spotify"])
        #expect(summary.budgetProgress?.budget.amount == 50)
        #expect(summary.budgetProgress?.isOverBudget == false)
    }

    @Test("load falls back to USD when no profile")
    func loadWithoutProfile() async {
        let (vm, _, _, _) = await makeViewModel()
        await vm.load()
        guard case .loaded(let summary) = vm.state else {
            Issue.record("expected loaded; got \(vm.state)")
            return
        }
        #expect(summary.currencyCode == "USD")
        #expect(summary.budgetProgress == nil)
    }

    @Test("load sorts upcoming subscriptions by date and filters archived")
    func loadSortsUpcoming() async {
        let later = subscription(name: "Later", daysFromNow: 20)
        let sooner = subscription(name: "Sooner", daysFromNow: 3)
        let archived = subscription(name: "Archived", status: .archived, daysFromNow: 1)
        let beyondWindow = subscription(name: "Far", daysFromNow: 45)
        let (vm, _, _, _) = await makeViewModel(
            subscriptions: [later, sooner, archived, beyondWindow]
        )

        await vm.load()

        guard case .loaded(let summary) = vm.state else {
            Issue.record("expected loaded; got \(vm.state)")
            return
        }
        #expect(summary.upcoming.map(\.serviceName) == ["Sooner", "Later"])
    }

    @Test("load surfaces recent activity from payments newest-first")
    func loadRecentActivity() async {
        let sub = subscription(name: "Netflix")
        let older = PaymentRecord(
            subscriptionID: sub.id,
            subscriptionName: sub.serviceName,
            amount: sub.price,
            date: Date(timeIntervalSince1970: 1_600_000_000)
        )
        let newer = PaymentRecord(
            subscriptionID: sub.id,
            subscriptionName: sub.serviceName,
            amount: sub.price,
            date: Date(timeIntervalSince1970: 1_650_000_000)
        )
        let (vm, _, _, _) = await makeViewModel(
            subscriptions: [sub],
            payments: [older, newer]
        )

        await vm.load()

        guard case .loaded(let summary) = vm.state else {
            Issue.record("expected loaded; got \(vm.state)")
            return
        }
        #expect(summary.recentActivity.map(\.id) == [newer.id, older.id])
    }

    @Test("budgetProgress is nil when currency mismatch")
    func budgetCurrencyMismatch() async {
        let profile = UserProfile(
            displayName: "User",
            preferredCurrencyCode: "USD",
            monthlyBudget: Money(amount: 50, currencyCode: "EUR")
        )
        let (vm, _, _, _) = await makeViewModel(profile: profile)
        await vm.load()
        guard case .loaded(let summary) = vm.state else {
            Issue.record("expected loaded; got \(vm.state)")
            return
        }
        #expect(summary.budgetProgress == nil)
    }

    @Test("showSubscription forwards id to router")
    func showSubscriptionRoutes() async {
        let router = FakeDashboardRouter()
        let (vm, _, _, _) = await makeViewModel(router: router)
        let id = UUID()
        vm.showSubscription(id: id)
        #expect(router.showSubscriptionDetailIDs == [id])
    }

    @Test("showAllSubscriptions calls router.showSubscriptions")
    func showAllRoutes() async {
        let router = FakeDashboardRouter()
        let (vm, _, _, _) = await makeViewModel(router: router)
        vm.showAllSubscriptions()
        #expect(router.showSubscriptionsCallCount == 1)
    }
}
