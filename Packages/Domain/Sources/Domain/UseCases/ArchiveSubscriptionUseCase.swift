import Foundation

public struct ArchiveSubscriptionUseCase: Sendable {
    private let repository: any SubscriptionRepository
    private let reminderScheduling: (any SubscriptionReminderScheduling)?

    public init(
        repository: any SubscriptionRepository,
        reminderScheduling: (any SubscriptionReminderScheduling)? = nil
    ) {
        self.repository = repository
        self.reminderScheduling = reminderScheduling
    }

    public func execute(id: UUID) async throws {
        guard var subscription = try await repository.fetch(id: id) else { return }
        subscription.status = .archived
        try await repository.save(subscription)
        try await reminderScheduling?.cancel(subscriptionID: id)
    }
}
