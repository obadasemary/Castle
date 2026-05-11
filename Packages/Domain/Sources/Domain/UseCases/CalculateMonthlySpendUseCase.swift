import Core

public struct CalculateMonthlySpendUseCase: Sendable {
    private let repository: any SubscriptionRepository

    public init(repository: any SubscriptionRepository) {
        self.repository = repository
    }

    public func execute(currencyCode: String) async throws -> Money {
        let active = try await repository.fetchAll().filter { $0.status == .active }
        let total = active.reduce(Decimal.zero) { sum, sub in
            let monthly = BillingCycleCalculator.monthlyEquivalent(price: sub.price, cycle: sub.billingCycle)
            guard monthly.currencyCode == currencyCode else { return sum }
            return sum + monthly.amount
        }
        return Money(amount: total, currencyCode: currencyCode)
    }
}
