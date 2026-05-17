import Testing
import Foundation
import Core
@testable import Domain

@Suite("BuildCategoryBreakdownUseCase")
struct BuildCategoryBreakdownUseCaseTests {
    @Test("Returns breakdown sorted by total descending")
    func sortedByTotal() async throws {
        let repo = FakeSubscriptionRepository()
        let future = Date().addingTimeInterval(86400 * 30)

        let ent1 = Subscription(serviceName: "Netflix", category: .entertainment, price: Money(amount: 10, currencyCode: "USD"), billingCycle: .monthly, nextBillingDate: future)
        let ent2 = Subscription(serviceName: "Disney", category: .entertainment, price: Money(amount: 8, currencyCode: "USD"), billingCycle: .monthly, nextBillingDate: future)
        let music = Subscription(serviceName: "Spotify", category: .music, price: Money(amount: 5, currencyCode: "USD"), billingCycle: .monthly, nextBillingDate: future)

        for sub in [ent1, ent2, music] { try await repo.save(sub) }

        let useCase = BuildCategoryBreakdownUseCase(repository: repo)
        let result = try await useCase.execute(currencyCode: "USD")

        #expect(result.count == 2)
        #expect(result[0].category == .entertainment)
        #expect(result[0].total.amount == 18)
        #expect(result[1].category == .music)
        #expect(abs(result[0].percentage - (18.0 / 23.0 * 100)) < 0.01)
    }

    @Test("Returns empty when no active subscriptions")
    func emptyWhenNoActive() async throws {
        let repo = FakeSubscriptionRepository()
        let useCase = BuildCategoryBreakdownUseCase(repository: repo)
        let result = try await useCase.execute(currencyCode: "USD")
        #expect(result.isEmpty)
    }
}
