import Testing
import Foundation
import Core
import Domain
@testable import Data

@Suite("SwiftDataUserProfileRepository")
struct SwiftDataUserProfileRepositoryTests {
    @Test("fetchProfile returns nil when no profile has been saved")
    func fetchProfileReturnsNilInitially() async throws {
        let container = try ModelContainerFactory.inMemory()
        let repo = SwiftDataUserProfileRepository(modelContainer: container)

        let profile = try await repo.fetchProfile()

        #expect(profile == nil)
    }

    @Test("saveProfile then fetchProfile round-trips all fields including monthly budget")
    func saveProfileRoundTrips() async throws {
        let container = try ModelContainerFactory.inMemory()
        let repo = SwiftDataUserProfileRepository(modelContainer: container)
        let profile = UserProfile(
            id: UUID(),
            displayName: "Obada",
            preferredCurrencyCode: "USD",
            monthlyBudget: Money(amount: Decimal(string: "200.00")!, currencyCode: "USD"),
            appearance: .dark
        )

        try await repo.saveProfile(profile)
        let fetched = try await repo.fetchProfile()

        #expect(fetched == profile)
    }

    @Test("saveProfile with the same id updates rather than inserts a new row")
    func saveProfileUpdatesExisting() async throws {
        let container = try ModelContainerFactory.inMemory()
        let repo = SwiftDataUserProfileRepository(modelContainer: container)
        let id = UUID()
        try await repo.saveProfile(UserProfile(id: id, displayName: "First"))
        try await repo.saveProfile(UserProfile(id: id, displayName: "Second"))

        let fetched = try await repo.fetchProfile()
        #expect(fetched?.displayName == "Second")
    }

    @Test("saveProfile preserves a nil monthlyBudget through a round-trip")
    func saveProfileWithoutBudget() async throws {
        let container = try ModelContainerFactory.inMemory()
        let repo = SwiftDataUserProfileRepository(modelContainer: container)
        let profile = UserProfile(id: UUID(), displayName: "Test", monthlyBudget: nil)

        try await repo.saveProfile(profile)
        let fetched = try await repo.fetchProfile()

        #expect(fetched?.monthlyBudget == nil)
    }
}
