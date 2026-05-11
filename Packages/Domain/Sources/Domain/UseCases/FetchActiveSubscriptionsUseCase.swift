public struct FetchActiveSubscriptionsUseCase: Sendable {
    private let repository: any SubscriptionRepository

    public init(repository: any SubscriptionRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [Subscription] {
        let all = try await repository.fetchAll()
        return all
            .filter { $0.status == .active }
            .sorted { $0.nextBillingDate < $1.nextBillingDate }
    }
}
