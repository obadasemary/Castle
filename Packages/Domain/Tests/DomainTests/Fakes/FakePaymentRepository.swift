import Foundation
import Domain
import Core

final class FakePaymentRepository: PaymentRepository, @unchecked Sendable {
    var records: [PaymentRecord] = []
    var deletedSubscriptionIDs: [UUID] = []

    func fetchAll(subscriptionID: UUID) async throws -> [PaymentRecord] {
        records.filter { $0.subscriptionID == subscriptionID }
    }

    func fetchRecent(limit: Int) async throws -> [PaymentRecord] {
        Array(records.sorted { $0.date > $1.date }.prefix(limit))
    }

    func fetchPayments(from: Date, to: Date, currencyCode: String) async throws -> [PaymentRecord] {
        records.filter {
            $0.amount.currencyCode == currencyCode && $0.date >= from && $0.date <= to
        }
    }

    func save(_ record: PaymentRecord) async throws {
        records.append(record)
    }

    func deleteAll(subscriptionID: UUID) async throws {
        records.removeAll { $0.subscriptionID == subscriptionID }
        deletedSubscriptionIDs.append(subscriptionID)
    }
}
