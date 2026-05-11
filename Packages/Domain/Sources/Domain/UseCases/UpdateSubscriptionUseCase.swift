public struct UpdateSubscriptionUseCase: Sendable {
    private let repository: any SubscriptionRepository
    private let reminderScheduling: (any SubscriptionReminderScheduling)?

    public init(
        repository: any SubscriptionRepository,
        reminderScheduling: (any SubscriptionReminderScheduling)? = nil
    ) {
        self.repository = repository
        self.reminderScheduling = reminderScheduling
    }

    public func execute(_ subscription: Subscription) async throws {
        try await repository.save(subscription)
        if let offset = subscription.reminderOffset {
            try await reminderScheduling?.reschedule(subscription: subscription, leadDays: offset)
        } else {
            try await reminderScheduling?.cancel(subscriptionID: subscription.id)
        }
    }
}
