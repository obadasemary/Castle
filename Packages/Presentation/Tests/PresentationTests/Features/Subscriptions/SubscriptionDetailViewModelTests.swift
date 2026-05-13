import Foundation
import Testing
import Core
import Domain
@testable import Presentation

@Suite("SubscriptionDetailViewModel")
@MainActor
struct SubscriptionDetailViewModelTests {
    private func makeViewModel(
        existing: [Subscription] = [],
        targetID: UUID,
        clockNow: Date = Date(timeIntervalSince1970: 1_700_000_000),
        router: FakeSubscriptionsRouter? = nil
    ) async -> (SubscriptionDetailViewModel, FakeSubscriptionRepository, FakePaymentRepository, FakeReminderScheduling) {
        let repo = FakeSubscriptionRepository()
        for sub in existing { await repo.seed(sub) }
        let payments = FakePaymentRepository()
        let scheduling = FakeReminderScheduling()
        let clock = FakeClock(now: clockNow)
        let calendar = FakeCalendarProvider()
        let vm = SubscriptionDetailViewModel(
            subscriptionID: targetID,
            fetchDetail: FetchSubscriptionDetailUseCase(
                subscriptionRepository: repo,
                paymentRepository: payments,
                clock: clock,
                calendarProvider: calendar
            ),
            updateUseCase: UpdateSubscriptionUseCase(repository: repo, reminderScheduling: scheduling),
            archiveUseCase: ArchiveSubscriptionUseCase(repository: repo, reminderScheduling: scheduling),
            deleteUseCase: DeleteSubscriptionUseCase(
                subscriptionRepository: repo,
                paymentRepository: payments,
                reminderScheduling: scheduling
            ),
            router: router
        )
        return (vm, repo, payments, scheduling)
    }

    private func sample(reminderOffset: Int? = nil) -> Subscription {
        Subscription(
            serviceName: "Netflix",
            category: .entertainment,
            price: Money(amount: 15.99, currencyCode: "USD"),
            billingCycle: .monthly,
            nextBillingDate: Date(timeIntervalSince1970: 1_700_000_000 + 7 * 86_400),
            reminderOffset: reminderOffset
        )
    }

    @Test("load populates detail with payment history sorted desc")
    func loadPopulatesDetail() async {
        let sub = sample()
        let (vm, _, payments, _) = await makeViewModel(existing: [sub], targetID: sub.id)
        let earlier = PaymentRecord(subscriptionID: sub.id, subscriptionName: sub.serviceName, amount: sub.price, date: Date(timeIntervalSince1970: 1_600_000_000))
        let later = PaymentRecord(subscriptionID: sub.id, subscriptionName: sub.serviceName, amount: sub.price, date: Date(timeIntervalSince1970: 1_650_000_000))
        await payments.seed(earlier)
        await payments.seed(later)

        await vm.load()

        guard case .loaded(let detail) = vm.state else {
            Issue.record("expected loaded")
            return
        }
        #expect(detail.subscription.id == sub.id)
        #expect(detail.paymentHistory.map(\.id) == [later.id, earlier.id])
        #expect(detail.daysUntilNextBilling == 7)
    }

    @Test("load returns notFound when missing")
    func loadNotFound() async {
        let (vm, _, _, _) = await makeViewModel(targetID: UUID())
        await vm.load()
        if case .notFound = vm.state {
            #expect(true)
        } else {
            Issue.record("expected notFound; got \(vm.state)")
        }
    }

    @Test("toggleReminder enabled sets offset and reschedules")
    func toggleReminderEnabled() async {
        let sub = sample(reminderOffset: nil)
        let (vm, repo, _, scheduling) = await makeViewModel(existing: [sub], targetID: sub.id)
        await vm.load()

        await vm.toggleReminder(enabled: true, leadDays: 3)

        #expect(await repo.subscriptions[sub.id]?.reminderOffset == 3)
        #expect(await scheduling.scheduledLeadDays[sub.id] == 3)
        #expect(vm.isReminderEnabled)
    }

    @Test("toggleReminder disabled clears offset and cancels")
    func toggleReminderDisabled() async {
        let sub = sample(reminderOffset: 2)
        let (vm, repo, _, scheduling) = await makeViewModel(existing: [sub], targetID: sub.id)
        await vm.load()

        await vm.toggleReminder(enabled: false)

        #expect(await repo.subscriptions[sub.id]?.reminderOffset == nil)
        #expect(await scheduling.canceledIDs.contains(sub.id))
        #expect(vm.isReminderEnabled == false)
    }

    @Test("archive flips status and dismisses via router")
    func archiveDismisses() async {
        let sub = sample()
        let router = FakeSubscriptionsRouter()
        let (vm, repo, _, _) = await makeViewModel(existing: [sub], targetID: sub.id, router: router)
        await vm.load()

        await vm.archive()

        #expect(await repo.subscriptions[sub.id]?.status == .archived)
        #expect(router.dismissCallCount == 1)
    }

    @Test("delete removes subscription and dismisses")
    func deleteDismisses() async {
        let sub = sample()
        let router = FakeSubscriptionsRouter()
        let (vm, repo, _, _) = await makeViewModel(existing: [sub], targetID: sub.id, router: router)
        await vm.load()

        await vm.delete()

        #expect(await repo.deletedIDs.contains(sub.id))
        #expect(router.dismissCallCount == 1)
    }
}
