import Core

public struct CategorySpend: Hashable, Sendable {
    public let category: Category
    public let total: Money
    public let percentage: Double

    public init(category: Category, total: Money, percentage: Double) {
        self.category = category
        self.total = total
        self.percentage = percentage
    }
}

public struct BuildCategoryBreakdownUseCase: Sendable {
    private let repository: any SubscriptionRepository

    public init(repository: any SubscriptionRepository) {
        self.repository = repository
    }

    public func execute(currencyCode: String) async throws -> [CategorySpend] {
        let active = try await repository.fetchAll().filter { $0.status == .active }
        var breakdown: [Category: Decimal] = [:]
        for sub in active {
            let monthly = BillingCycleCalculator.monthlyEquivalent(price: sub.price, cycle: sub.billingCycle)
            guard monthly.currencyCode == currencyCode else { continue }
            breakdown[sub.category, default: 0] += monthly.amount
        }
        let grandTotal = breakdown.values.reduce(0, +)
        guard grandTotal > 0 else { return [] }
        return breakdown
            .map { category, amount in
                CategorySpend(
                    category: category,
                    total: Money(amount: amount, currencyCode: currencyCode),
                    percentage: Double(truncating: (amount / grandTotal * 100) as NSDecimalNumber)
                )
            }
            .sorted { $0.total.amount > $1.total.amount }
    }
}
