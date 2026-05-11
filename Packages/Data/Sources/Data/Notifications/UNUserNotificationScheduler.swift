#if canImport(UserNotifications)
import Foundation
import UserNotifications
import Domain

public struct UNUserNotificationScheduler: SubscriptionReminderScheduling {
    public init() {}

    public func schedule(subscription: Subscription, leadDays: Int) async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        guard granted else { return }

        let calendar = Calendar.current
        let triggerDate = calendar.date(
            byAdding: .day,
            value: -leadDays,
            to: subscription.nextBillingDate
        ) ?? subscription.nextBillingDate

        let content = UNMutableNotificationContent()
        content.title = "Upcoming: \(subscription.serviceName)"
        content.body = "Renews on \(subscription.nextBillingDate.formatted(date: .abbreviated, time: .omitted))."
        content.sound = .default

        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: Self.identifier(for: subscription.id),
            content: content,
            trigger: trigger
        )
        try await center.add(request)
    }

    public func reschedule(subscription: Subscription, leadDays: Int) async throws {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.identifier(for: subscription.id)])
        try await schedule(subscription: subscription, leadDays: leadDays)
    }

    public func cancel(subscriptionID: UUID) async throws {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.identifier(for: subscriptionID)])
    }

    private static func identifier(for subscriptionID: UUID) -> String {
        "castle.reminder.\(subscriptionID.uuidString)"
    }
}
#endif
