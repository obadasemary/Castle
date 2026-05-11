import Testing
import Foundation
import Core
import Domain
@testable import Data

@Suite("BundledPopularServicesCatalog")
struct BundledPopularServicesCatalogTests {
    @Test("fetchAll returns the curated nine-service seed")
    func fetchAllReturnsCuratedSeed() async throws {
        let catalog = BundledPopularServicesCatalog()
        let services = try await catalog.fetchAll()

        let expected = [
            "Netflix", "Spotify", "YouTube Premium", "ChatGPT Plus",
            "Claude Pro", "Notion", "Disney+", "Amazon Prime", "Dropbox"
        ]
        #expect(services.map(\.name) == expected)
    }

    @Test("ids are stable across calls (deterministic seed)")
    func idsStableAcrossCalls() async throws {
        let catalog = BundledPopularServicesCatalog()
        let first = try await catalog.fetchAll()
        let second = try await catalog.fetchAll()

        #expect(first.map(\.id) == second.map(\.id))
    }

    @Test("brand color hex values are well-formed seven-character strings")
    func brandColorsAreSevenCharHex() async throws {
        let services = try await BundledPopularServicesCatalog().fetchAll()
        for service in services {
            #expect(service.brandColorHex.count == 7, "\(service.name) hex must be 7 chars (got '\(service.brandColorHex)')")
            #expect(service.brandColorHex.hasPrefix("#"))
        }
    }
}
