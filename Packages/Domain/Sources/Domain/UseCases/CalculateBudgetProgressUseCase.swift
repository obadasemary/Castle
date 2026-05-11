import Core
import Foundation

public struct BudgetProgress: Sendable {
    public let spent: Money
    public let budget: Money
    public let fraction: Double  // 0...1, capped at 1.0
    public let isOverBudget: Bool

    public init(spent: Money, budget: Money, fraction: Double, isOverBudget: Bool) {
        self.spent = spent
        self.budget = budget
        self.fraction = fraction
        self.isOverBudget = isOverBudget
    }
}

public struct CalculateBudgetProgressUseCase: Sendable {
    private let subscriptionRepository: any SubscriptionRepository
    private let userProfileRepository: any UserProfileRepository

    public init(
        subscriptionRepository: any SubscriptionRepository,
        userProfileRepository: any UserProfileRepository
    ) {
        self.subscriptionRepository = subscriptionRepository
        self.userProfileRepository = userProfileRepository
    }

    public func execute(currencyCode: String) async throws -> BudgetProgress? {
        guard let profile = try await userProfileRepository.fetchProfile(),
              let budget = profile.monthlyBudget,
              budget.currencyCode == currencyCode,
              budget.amount > 0
        else { return nil }

        let active = try await subscriptionRepository.fetchAll().filter { $0.status == .active }
        let spentAmount = active.reduce(into: Decimal.zero) { sum, sub in
            let monthly = BillingCycleCalculator.monthlyEquivalent(price: sub.price, cycle: sub.billingCycle)
            guard monthly.currencyCode == currencyCode else { return }
            sum += monthly.amount
        }
        let spent = Money(amount: spentAmount, currencyCode: currencyCode)
        let fraction = min(
            Double(truncating: (spentAmount / budget.amount) as NSDecimalNumber),
            1.0
        )
        return BudgetProgress(
            spent: spent,
            budget: budget,
            fraction: fraction,
            isOverBudget: spentAmount > budget.amount
        )
    }
}
