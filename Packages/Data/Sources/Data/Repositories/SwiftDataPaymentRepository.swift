import Foundation
import SwiftData
import Domain

@ModelActor
public actor SwiftDataPaymentRepository: PaymentRepository {
    public func fetchAll(subscriptionID: UUID) async throws -> [PaymentRecord] {
        let targetID = subscriptionID
        let descriptor = FetchDescriptor<PaymentRecordModel>(
            predicate: #Predicate { $0.subscriptionID == targetID },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map(PaymentRecordMapper.toDomain)
    }

    public func fetchRecent(limit: Int) async throws -> [PaymentRecord] {
        var descriptor = FetchDescriptor<PaymentRecordModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        let models = try modelContext.fetch(descriptor)
        return models.map(PaymentRecordMapper.toDomain)
    }

    public func fetchPayments(from: Date, to: Date, currencyCode: String) async throws -> [PaymentRecord] {
        let startDate = from
        let endDate = to
        let currency = currencyCode
        let descriptor = FetchDescriptor<PaymentRecordModel>(
            predicate: #Predicate { record in
                record.date >= startDate &&
                record.date < endDate &&
                record.amountCurrencyCode == currency
            },
            sortBy: [SortDescriptor(\.date)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map(PaymentRecordMapper.toDomain)
    }

    public func save(_ record: PaymentRecord) async throws {
        let targetID = record.id
        let descriptor = FetchDescriptor<PaymentRecordModel>(
            predicate: #Predicate { $0.id == targetID }
        )
        if try modelContext.fetch(descriptor).first == nil {
            modelContext.insert(PaymentRecordMapper.makeModel(from: record))
            try modelContext.save()
        }
    }

    public func deleteAll(subscriptionID: UUID) async throws {
        let targetID = subscriptionID
        let descriptor = FetchDescriptor<PaymentRecordModel>(
            predicate: #Predicate { $0.subscriptionID == targetID }
        )
        for model in try modelContext.fetch(descriptor) {
            modelContext.delete(model)
        }
        try modelContext.save()
    }
}
