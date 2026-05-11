import Testing
import Foundation
import Core
import Domain
@testable import Data

@Suite("SwiftDataPaymentRepository")
struct SwiftDataPaymentRepositoryTests {
    @Test("save then fetchAll returns payments for the same subscription")
    func saveThenFetchAll() async throws {
        let repo = try makeRepository()
        let subscriptionID = UUID()
        try await repo.save(makePayment(subscriptionID: subscriptionID))

        let payments = try await repo.fetchAll(subscriptionID: subscriptionID)

        #expect(payments.count == 1)
        #expect(payments.first?.subscriptionID == subscriptionID)
    }

    @Test("fetchAll only returns payments for the requested subscription")
    func fetchAllFiltersBySubscription() async throws {
        let repo = try makeRepository()
        let netflixID = UUID()
        let spotifyID = UUID()
        try await repo.save(makePayment(subscriptionID: netflixID, name: "Netflix"))
        try await repo.save(makePayment(subscriptionID: spotifyID, name: "Spotify"))

        let netflixPayments = try await repo.fetchAll(subscriptionID: netflixID)

        #expect(netflixPayments.count == 1)
        #expect(netflixPayments.first?.subscriptionName == "Netflix")
    }

    @Test("fetchRecent returns the most recent payments up to the limit")
    func fetchRecentHonoursLimit() async throws {
        let repo = try makeRepository()
        let base = Date(timeIntervalSince1970: 1_750_000_000)
        for offset in 0..<5 {
            try await repo.save(makePayment(
                subscriptionID: UUID(),
                date: base.addingTimeInterval(Double(offset) * 86400)
            ))
        }

        let recent = try await repo.fetchRecent(limit: 3)

        #expect(recent.count == 3)
        #expect(recent.first!.date > recent.last!.date)
    }

    @Test("fetchPayments(from:to:currencyCode:) filters by date window and currency")
    func fetchPaymentsFiltersWindowAndCurrency() async throws {
        let repo = try makeRepository()
        let now = Date(timeIntervalSince1970: 1_750_000_000)
        let windowStart = now
        let windowEnd = now.addingTimeInterval(86400 * 7)

        try await repo.save(makePayment(date: now.addingTimeInterval(86400), currencyCode: "USD"))
        try await repo.save(makePayment(date: now.addingTimeInterval(86400 * 3), currencyCode: "USD"))
        try await repo.save(makePayment(date: now.addingTimeInterval(-86400), currencyCode: "USD"))   // before window
        try await repo.save(makePayment(date: now.addingTimeInterval(86400 * 10), currencyCode: "USD")) // after window
        try await repo.save(makePayment(date: now.addingTimeInterval(86400), currencyCode: "EUR"))    // wrong currency

        let usd = try await repo.fetchPayments(from: windowStart, to: windowEnd, currencyCode: "USD")

        #expect(usd.count == 2)
        #expect(usd.allSatisfy { $0.amount.currencyCode == "USD" })
    }

    @Test("save is idempotent: saving the same record twice yields one row")
    func saveIsIdempotent() async throws {
        let repo = try makeRepository()
        let subID = UUID()
        let record = makePayment(subscriptionID: subID)
        try await repo.save(record)
        try await repo.save(record)

        let all = try await repo.fetchAll(subscriptionID: subID)
        #expect(all.count == 1)
    }

    @Test("deleteAll(subscriptionID:) removes only that subscription's payments")
    func deleteAllRemovesScoped() async throws {
        let repo = try makeRepository()
        let netflixID = UUID()
        let spotifyID = UUID()
        try await repo.save(makePayment(subscriptionID: netflixID))
        try await repo.save(makePayment(subscriptionID: spotifyID))

        try await repo.deleteAll(subscriptionID: netflixID)

        #expect(try await repo.fetchAll(subscriptionID: netflixID).isEmpty)
        #expect(try await repo.fetchAll(subscriptionID: spotifyID).count == 1)
    }

    // MARK: - Helpers

    private func makeRepository() throws -> SwiftDataPaymentRepository {
        let container = try ModelContainerFactory.inMemory()
        return SwiftDataPaymentRepository(modelContainer: container)
    }

    private func makePayment(
        id: UUID = UUID(),
        subscriptionID: UUID = UUID(),
        name: String = "Service",
        amount: Decimal = Decimal(string: "9.99")!,
        currencyCode: String = "USD",
        date: Date = Date(timeIntervalSince1970: 1_750_000_000)
    ) -> PaymentRecord {
        PaymentRecord(
            id: id,
            subscriptionID: subscriptionID,
            subscriptionName: name,
            amount: Money(amount: amount, currencyCode: currencyCode),
            date: date
        )
    }
}
