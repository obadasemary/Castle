import Testing
import Foundation
import Core
import Domain
@testable import Data

@Suite("SwiftDataSubscriptionRepository")
struct SwiftDataSubscriptionRepositoryTests {
    @Test("save then fetchAll returns the saved subscription")
    func saveThenFetchAll() async throws {
        let repo = try makeRepository()
        let netflix = makeSubscription(name: "Netflix")

        try await repo.save(netflix)
        let all = try await repo.fetchAll()

        #expect(all.count == 1)
        #expect(all.first?.serviceName == "Netflix")
        #expect(all.first?.id == netflix.id)
    }

    @Test("fetchAll is sorted ascending by nextBillingDate")
    func fetchAllSortedAscending() async throws {
        let repo = try makeRepository()
        let now = Date(timeIntervalSince1970: 1_750_000_000)
        try await repo.save(makeSubscription(name: "Later", nextBillingDate: now.addingTimeInterval(86400 * 30)))
        try await repo.save(makeSubscription(name: "Sooner", nextBillingDate: now.addingTimeInterval(86400 * 5)))

        let all = try await repo.fetchAll()

        #expect(all.map(\.serviceName) == ["Sooner", "Later"])
    }

    @Test("fetch(id:) returns the matching subscription")
    func fetchByID() async throws {
        let repo = try makeRepository()
        let spotify = makeSubscription(name: "Spotify")
        try await repo.save(spotify)

        let found = try await repo.fetch(id: spotify.id)

        #expect(found?.serviceName == "Spotify")
    }

    @Test("fetch(id:) returns nil when the id is unknown")
    func fetchByIDUnknownReturnsNil() async throws {
        let repo = try makeRepository()
        let found = try await repo.fetch(id: UUID())
        #expect(found == nil)
    }

    @Test("save with the same id updates the existing row rather than inserting")
    func saveUpdatesExisting() async throws {
        let repo = try makeRepository()
        let id = UUID()
        try await repo.save(makeSubscription(id: id, name: "Netflix"))
        try await repo.save(makeSubscription(id: id, name: "Netflix Premium"))

        let all = try await repo.fetchAll()
        #expect(all.count == 1)
        #expect(all.first?.serviceName == "Netflix Premium")
    }

    @Test("delete(id:) removes the matching subscription")
    func deleteRemoves() async throws {
        let repo = try makeRepository()
        let netflix = makeSubscription(name: "Netflix")
        try await repo.save(netflix)

        try await repo.delete(id: netflix.id)

        #expect(try await repo.fetchAll().isEmpty)
        #expect(try await repo.fetch(id: netflix.id) == nil)
    }

    @Test("billingCycle round-trips through storage including custom days")
    func billingCycleRoundTrips() async throws {
        let repo = try makeRepository()
        let monthly = makeSubscription(name: "Monthly", billingCycle: .monthly)
        let annual = makeSubscription(name: "Annual", billingCycle: .annual)
        let custom = makeSubscription(name: "Custom", billingCycle: .custom(days: 14))

        try await repo.save(monthly)
        try await repo.save(annual)
        try await repo.save(custom)

        let byName = Dictionary(uniqueKeysWithValues: try await repo.fetchAll().map { ($0.serviceName, $0.billingCycle) })
        #expect(byName["Monthly"] == .monthly)
        #expect(byName["Annual"] == .annual)
        #expect(byName["Custom"] == .custom(days: 14))
    }

    // MARK: - Helpers

    private func makeRepository() throws -> SwiftDataSubscriptionRepository {
        let container = try ModelContainerFactory.inMemory()
        return SwiftDataSubscriptionRepository(modelContainer: container)
    }

    private func makeSubscription(
        id: UUID = UUID(),
        name: String,
        billingCycle: BillingCycle = .monthly,
        nextBillingDate: Date = Date(timeIntervalSince1970: 1_750_000_000)
    ) -> Subscription {
        Subscription(
            id: id,
            serviceName: name,
            category: .entertainment,
            price: Money(amount: Decimal(string: "9.99")!, currencyCode: "USD"),
            billingCycle: billingCycle,
            nextBillingDate: nextBillingDate
        )
    }
}
