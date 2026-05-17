import Foundation
import Core

public protocol PaymentRepository: Sendable {
    func fetchAll(subscriptionID: UUID) async throws -> [PaymentRecord]
    func fetchRecent(limit: Int) async throws -> [PaymentRecord]
    func fetchPayments(from: Date, to: Date, currencyCode: String) async throws -> [PaymentRecord]
    func save(_ record: PaymentRecord) async throws
    func deleteAll(subscriptionID: UUID) async throws
}
