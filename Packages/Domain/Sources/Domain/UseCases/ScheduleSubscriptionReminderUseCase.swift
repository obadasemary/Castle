import Foundation

public struct ScheduleSubscriptionReminderUseCase: Sendable {
    private let subscriptionRepository: any SubscriptionRepository
    private let reminderScheduling: any SubscriptionReminderScheduling

    public init(
        subscriptionRepository: any SubscriptionRepository,
        reminderScheduling: any SubscriptionReminderScheduling
    ) {
        self.subscriptionRepository = subscriptionRepository
        self.reminderScheduling = reminderScheduling
    }

    public func execute(subscriptionID: UUID, leadDays: Int) async throws {
        if leadDays > 0 {
            guard let subscription = try await subscriptionRepository.fetch(id: subscriptionID) else { return }
            try await reminderScheduling.schedule(subscription: subscription, leadDays: leadDays)
        } else {
            try await reminderScheduling.cancel(subscriptionID: subscriptionID)
        }
    }
}
