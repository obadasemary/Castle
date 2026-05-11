import Testing
import Foundation
import Core
@testable import Domain

@Suite("CalculateMonthlySpendUseCase")
struct CalculateMonthlySpendUseCaseTests {
    @Test("Sums monthly equivalents for active subscriptions")
    func sumsMonthlyEquivalents() async throws {
        let repo = FakeSubscriptionRepository()
        let futureDate = Date().addingTimeInterval(86400 * 30)

        let monthly = Subscription(serviceName: "Netflix", category: .entertainment, price: Money(amount: 10, currencyCode: "USD"), billingCycle: .monthly, nextBillingDate: futureDate)
        let annual = Subscription(serviceName: "Notion", category: .productivity, price: Money(amount: 120, currencyCode: "USD"), billingCycle: .annual, nextBillingDate: futureDate)
        let archived = Subscription(serviceName: "Old", category: .other, price: Money(amount: 50, currencyCode: "USD"), billingCycle: .monthly, nextBillingDate: futureDate, status: .archived)

        for sub in [monthly, annual, archived] { try await repo.save(sub) }

        let useCase = CalculateMonthlySpendUseCase(repository: repo)
        let result = try await useCase.execute(currencyCode: "USD")

        #expect(result.amount == 20)
        #expect(result.currencyCode == "USD")
    }

    @Test("Returns zero when no active subscriptions")
    func zeroWhenEmpty() async throws {
        let repo = FakeSubscriptionRepository()
        let useCase = CalculateMonthlySpendUseCase(repository: repo)
        let result = try await useCase.execute(currencyCode: "USD")
        #expect(result.amount == 0)
    }
}
