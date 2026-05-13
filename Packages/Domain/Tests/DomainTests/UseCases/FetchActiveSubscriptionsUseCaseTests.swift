import Testing
import Foundation
import Core
@testable import Domain

@Suite("FetchActiveSubscriptionsUseCase")
struct FetchActiveSubscriptionsUseCaseTests {
    private func makeSubscription(name: String, status: Subscription.Status, daysFromNow: Int) -> Subscription {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .gmt
        let nextBilling = cal.date(byAdding: .day, value: daysFromNow, to: Date()) ?? Date()
        return Subscription(
            serviceName: name,
            category: .entertainment,
            price: Money(amount: 9.99, currencyCode: "USD"),
            billingCycle: .monthly,
            nextBillingDate: nextBilling,
            status: status
        )
    }

    @Test("Returns only active subscriptions sorted by billing date")
    func onlyActiveReturned() async throws {
        let repo = FakeSubscriptionRepository()
        let active1 = makeSubscription(name: "Netflix", status: .active, daysFromNow: 5)
        let active2 = makeSubscription(name: "Spotify", status: .active, daysFromNow: 2)
        let archived = makeSubscription(name: "Old", status: .archived, daysFromNow: 1)
        for sub in [active1, active2, archived] { try await repo.save(sub) }

        let useCase = FetchActiveSubscriptionsUseCase(repository: repo)
        let result = try await useCase.execute()

        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.status == .active })
        #expect(result[0].nextBillingDate <= result[1].nextBillingDate)
    }

    @Test("Empty repository returns empty list")
    func emptyRepository() async throws {
        let repo = FakeSubscriptionRepository()
        let useCase = FetchActiveSubscriptionsUseCase(repository: repo)
        let result = try await useCase.execute()
        #expect(result.isEmpty)
    }
}
