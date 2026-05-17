import Foundation

public struct DeleteSubscriptionUseCase: Sendable {
    private let subscriptionRepository: any SubscriptionRepository
    private let paymentRepository: any PaymentRepository
    private let reminderScheduling: (any SubscriptionReminderScheduling)?

    public init(
        subscriptionRepository: any SubscriptionRepository,
        paymentRepository: any PaymentRepository,
        reminderScheduling: (any SubscriptionReminderScheduling)? = nil
    ) {
        self.subscriptionRepository = subscriptionRepository
        self.paymentRepository = paymentRepository
        self.reminderScheduling = reminderScheduling
    }

    public func execute(id: UUID) async throws {
        try await subscriptionRepository.delete(id: id)
        try await paymentRepository.deleteAll(subscriptionID: id)
        try await reminderScheduling?.cancel(subscriptionID: id)
    }
}
