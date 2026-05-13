import Foundation
import Testing
import Core
import Domain
@testable import Presentation

@Suite("SubscriptionsListViewModel")
@MainActor
struct SubscriptionsListViewModelTests {
    private func makeViewModel(
        subscriptions: [Subscription] = [],
        router: FakeSubscriptionsRouter? = nil
    ) async -> (SubscriptionsListViewModel, FakeSubscriptionRepository, FakePaymentRepository, FakeReminderScheduling) {
        let repo = FakeSubscriptionRepository()
        for sub in subscriptions { await repo.seed(sub) }
        let payments = FakePaymentRepository()
        let scheduling = FakeReminderScheduling()
        let vm = SubscriptionsListViewModel(
            repository: repo,
            fetchActive: FetchActiveSubscriptionsUseCase(repository: repo),
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

    private func subscription(name: String, status: Subscription.Status = .active, daysFromNow: Int = 7) -> Subscription {
        Subscription(
            serviceName: name,
            category: .entertainment,
            price: Money(amount: 9.99, currencyCode: "USD"),
            billingCycle: .monthly,
            nextBillingDate: Date().addingTimeInterval(TimeInterval(daysFromNow) * 86_400),
            status: status
        )
    }

    @Test("starts in idle state with active filter")
    func startsIdleActive() async {
        let (vm, _, _, _) = await makeViewModel()
        #expect(vm.state == .idle)
        #expect(vm.filter == .active)
    }

    @Test("load returns only active subscriptions sorted by nextBillingDate")
    func loadReturnsActiveSorted() async {
        let later = subscription(name: "Later", daysFromNow: 30)
        let sooner = subscription(name: "Sooner", daysFromNow: 3)
        let archived = subscription(name: "Old", status: .archived)
        let (vm, _, _, _) = await makeViewModel(subscriptions: [later, sooner, archived])

        await vm.load()

        guard case .loaded(let subs) = vm.state else {
            Issue.record("expected loaded; got \(vm.state)")
            return
        }
        #expect(subs.map(\.serviceName) == ["Sooner", "Later"])
    }

    @Test("setFilter to archived re-loads with archived subs")
    func setFilterArchived() async {
        let active = subscription(name: "Active")
        let archived = subscription(name: "Archived", status: .archived)
        let (vm, _, _, _) = await makeViewModel(subscriptions: [active, archived])

        await vm.load()
        await vm.setFilter(.archived)

        guard case .loaded(let subs) = vm.state else {
            Issue.record("expected loaded; got \(vm.state)")
            return
        }
        #expect(subs.map(\.serviceName) == ["Archived"])
        #expect(vm.filter == .archived)
    }

    @Test("archive flips status and reloads")
    func archiveFlipsStatus() async {
        let sub = subscription(name: "ToArchive")
        let (vm, repo, _, scheduling) = await makeViewModel(subscriptions: [sub])

        await vm.load()
        await vm.archive(id: sub.id)

        #expect(await repo.subscriptions[sub.id]?.status == .archived)
        #expect(await scheduling.canceledIDs.contains(sub.id))
        guard case .loaded(let subs) = vm.state else {
            Issue.record("expected loaded; got \(vm.state)")
            return
        }
        #expect(subs.isEmpty)
    }

    @Test("delete removes subscription and payment history")
    func deleteRemovesSubscriptionAndPayments() async {
        let sub = subscription(name: "ToDelete")
        let (vm, repo, payments, scheduling) = await makeViewModel(subscriptions: [sub])
        await payments.seed(PaymentRecord(
            subscriptionID: sub.id,
            subscriptionName: sub.serviceName,
            amount: sub.price,
            date: Date()
        ))

        await vm.delete(id: sub.id)

        #expect(await repo.deletedIDs.contains(sub.id))
        #expect(await payments.deletedSubscriptionIDs.contains(sub.id))
        #expect(await scheduling.canceledIDs.contains(sub.id))
    }

    @Test("presentAdd routes to router.presentAdd")
    func presentAddRoutesToRouter() async {
        let router = FakeSubscriptionsRouter()
        let (vm, _, _, _) = await makeViewModel(router: router)
        vm.presentAdd()
        #expect(router.presentAddCallCount == 1)
    }

    @Test("showDetail forwards id to router")
    func showDetailForwardsToRouter() async {
        let router = FakeSubscriptionsRouter()
        let (vm, _, _, _) = await makeViewModel(router: router)
        let id = UUID()
        vm.showDetail(id)
        #expect(router.showDetailIDs == [id])
    }
}
