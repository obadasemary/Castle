import Foundation

public protocol SubscriptionReminderScheduling: Sendable {
    func schedule(subscription: Subscription, leadDays: Int) async throws
    func reschedule(subscription: Subscription, leadDays: Int) async throws
    func cancel(subscriptionID: UUID) async throws
}
