import Foundation

public protocol SubscriptionRepository: Sendable {
    func fetchAll() async throws -> [Subscription]
    func fetch(id: UUID) async throws -> Subscription?
    func save(_ subscription: Subscription) async throws
    func delete(id: UUID) async throws
}
