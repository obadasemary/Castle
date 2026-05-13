import Foundation
import Domain

actor FakeReminderScheduling: SubscriptionReminderScheduling {
    var scheduledLeadDays: [UUID: Int] = [:]
    var canceledIDs: [UUID] = []

    func schedule(subscription: Subscription, leadDays: Int) async throws {
        scheduledLeadDays[subscription.id] = leadDays
    }

    func reschedule(subscription: Subscription, leadDays: Int) async throws {
        scheduledLeadDays[subscription.id] = leadDays
    }

    func cancel(subscriptionID: UUID) async throws {
        scheduledLeadDays.removeValue(forKey: subscriptionID)
        canceledIDs.append(subscriptionID)
    }
}
