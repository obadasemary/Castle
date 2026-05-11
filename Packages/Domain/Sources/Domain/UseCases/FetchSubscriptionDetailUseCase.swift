import Foundation
import Core

public struct FetchSubscriptionDetailUseCase: Sendable {
    private let subscriptionRepository: any SubscriptionRepository
    private let paymentRepository: any PaymentRepository
    private let clock: any Clock
    private let calendarProvider: any CalendarProvider

    public init(
        subscriptionRepository: any SubscriptionRepository,
        paymentRepository: any PaymentRepository,
        clock: any Clock,
        calendarProvider: any CalendarProvider
    ) {
        self.subscriptionRepository = subscriptionRepository
        self.paymentRepository = paymentRepository
        self.clock = clock
        self.calendarProvider = calendarProvider
    }

    public struct Detail: Sendable {
        public let subscription: Subscription
        public let paymentHistory: [PaymentRecord]
        public let daysUntilNextBilling: Int
    }

    public func execute(id: UUID) async throws -> Detail? {
        guard let subscription = try await subscriptionRepository.fetch(id: id) else { return nil }
        let payments = try await paymentRepository.fetchAll(subscriptionID: id)
        let days = BillingCycleCalculator.daysUntil(
            subscription.nextBillingDate,
            clock: clock,
            calendar: calendarProvider.calendar
        )
        return Detail(
            subscription: subscription,
            paymentHistory: payments.sorted { $0.date > $1.date },
            daysUntilNextBilling: days
        )
    }
}
