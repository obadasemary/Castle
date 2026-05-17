import Foundation
import Domain
import Core

final class FakePopularServicesCatalog: PopularServicesCatalog, Sendable {
    let services: [PopularService]

    init(services: [PopularService] = FakePopularServicesCatalog.defaultServices) {
        self.services = services
    }

    func fetchAll() async throws -> [PopularService] { services }

    static let defaultServices: [PopularService] = [
        PopularService(name: "Netflix", category: .entertainment, brandColorHex: "#E50914", iconSymbolName: "play.tv", defaultPrice: Money(amount: 15.99, currencyCode: "USD"), defaultBillingCycle: .monthly),
        PopularService(name: "Spotify", category: .music, brandColorHex: "#1DB954", iconSymbolName: "music.note", defaultPrice: Money(amount: 9.99, currencyCode: "USD"), defaultBillingCycle: .monthly),
        PopularService(name: "ChatGPT", category: .ai, brandColorHex: "#10A37F", iconSymbolName: "cpu", defaultPrice: Money(amount: 20.00, currencyCode: "USD"), defaultBillingCycle: .monthly)
    ]
}
