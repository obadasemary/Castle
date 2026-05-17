import Core

public struct AddSubscriptionUseCase: Sendable {
    private let repository: any SubscriptionRepository
    private let reminderScheduling: (any SubscriptionReminderScheduling)?

    public init(
        repository: any SubscriptionRepository,
        reminderScheduling: (any SubscriptionReminderScheduling)? = nil
    ) {
        self.repository = repository
        self.reminderScheduling = reminderScheduling
    }

    @discardableResult
    public func execute(_ input: SubscriptionInput) async throws -> Subscription {
        let subscription = Subscription(
            serviceName: input.serviceName,
            category: input.category,
            price: Money(amount: input.price, currencyCode: input.currencyCode),
            billingCycle: input.billingCycle,
            nextBillingDate: input.nextBillingDate,
            reminderOffset: input.reminderOffset,
            brandColorHex: input.brandColorHex,
            iconSymbolName: input.iconSymbolName,
            notes: input.notes
        )
        try await repository.save(subscription)
        if let offset = input.reminderOffset, offset > 0 {
            try await reminderScheduling?.schedule(subscription: subscription, leadDays: offset)
        }
        return subscription
    }
}
