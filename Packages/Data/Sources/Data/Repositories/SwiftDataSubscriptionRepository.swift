import Foundation
import SwiftData
import Domain

@ModelActor
public actor SwiftDataSubscriptionRepository: SubscriptionRepository {
    public func fetchAll() async throws -> [Subscription] {
        let descriptor = FetchDescriptor<SubscriptionModel>(
            sortBy: [SortDescriptor(\.nextBillingDate)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map(SubscriptionMapper.toDomain)
    }

    public func fetch(id: UUID) async throws -> Subscription? {
        let targetID = id
        let descriptor = FetchDescriptor<SubscriptionModel>(
            predicate: #Predicate { $0.id == targetID }
        )
        let models = try modelContext.fetch(descriptor)
        return models.first.map(SubscriptionMapper.toDomain)
    }

    public func save(_ subscription: Subscription) async throws {
        let targetID = subscription.id
        let descriptor = FetchDescriptor<SubscriptionModel>(
            predicate: #Predicate { $0.id == targetID }
        )
        if let existing = try modelContext.fetch(descriptor).first {
            SubscriptionMapper.apply(subscription, to: existing)
        } else {
            modelContext.insert(SubscriptionMapper.makeModel(from: subscription))
        }
        try modelContext.save()
    }

    public func delete(id: UUID) async throws {
        let targetID = id
        let descriptor = FetchDescriptor<SubscriptionModel>(
            predicate: #Predicate { $0.id == targetID }
        )
        for model in try modelContext.fetch(descriptor) {
            modelContext.delete(model)
        }
        try modelContext.save()
    }
}
