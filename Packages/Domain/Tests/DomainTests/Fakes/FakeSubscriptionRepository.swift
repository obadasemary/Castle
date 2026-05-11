import Foundation
import Domain

final class FakeSubscriptionRepository: SubscriptionRepository, @unchecked Sendable {
    var subscriptions: [UUID: Subscription] = [:]
    var savedCallCount = 0
    var deletedIDs: [UUID] = []

    func fetchAll() async throws -> [Subscription] {
        Array(subscriptions.values)
    }

    func fetch(id: UUID) async throws -> Subscription? {
        subscriptions[id]
    }

    func save(_ subscription: Subscription) async throws {
        subscriptions[subscription.id] = subscription
        savedCallCount += 1
    }

    func delete(id: UUID) async throws {
        subscriptions.removeValue(forKey: id)
        deletedIDs.append(id)
    }
}
