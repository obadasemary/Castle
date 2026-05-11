import Foundation
import Core
import Domain

public struct BundledPopularServicesCatalog: PopularServicesCatalog {
    public init() {}

    public func fetchAll() async throws -> [PopularService] {
        Self.services
    }

    private static let services: [PopularService] = [
        PopularService(
            id: deterministicID("netflix"),
            name: "Netflix",
            category: .entertainment,
            brandColorHex: "#E50914",
            iconSymbolName: "play.tv.fill",
            defaultPrice: Money(amount: Decimal(string: "15.99")!, currencyCode: "USD"),
            defaultBillingCycle: .monthly
        ),
        PopularService(
            id: deterministicID("spotify"),
            name: "Spotify",
            category: .music,
            brandColorHex: "#1DB954",
            iconSymbolName: "music.note",
            defaultPrice: Money(amount: Decimal(string: "11.99")!, currencyCode: "USD"),
            defaultBillingCycle: .monthly
        ),
        PopularService(
            id: deterministicID("youtube-premium"),
            name: "YouTube Premium",
            category: .entertainment,
            brandColorHex: "#FF0000",
            iconSymbolName: "play.rectangle.fill",
            defaultPrice: Money(amount: Decimal(string: "13.99")!, currencyCode: "USD"),
            defaultBillingCycle: .monthly
        ),
        PopularService(
            id: deterministicID("chatgpt-plus"),
            name: "ChatGPT Plus",
            category: .ai,
            brandColorHex: "#10A37F",
            iconSymbolName: "cpu",
            defaultPrice: Money(amount: Decimal(string: "20.00")!, currencyCode: "USD"),
            defaultBillingCycle: .monthly
        ),
        PopularService(
            id: deterministicID("claude-pro"),
            name: "Claude Pro",
            category: .ai,
            brandColorHex: "#D77757",
            iconSymbolName: "sparkles",
            defaultPrice: Money(amount: Decimal(string: "20.00")!, currencyCode: "USD"),
            defaultBillingCycle: .monthly
        ),
        PopularService(
            id: deterministicID("notion"),
            name: "Notion",
            category: .productivity,
            brandColorHex: "#000000",
            iconSymbolName: "doc.text.fill",
            defaultPrice: Money(amount: Decimal(string: "10.00")!, currencyCode: "USD"),
            defaultBillingCycle: .monthly
        ),
        PopularService(
            id: deterministicID("disney-plus"),
            name: "Disney+",
            category: .entertainment,
            brandColorHex: "#113CCF",
            iconSymbolName: "star.fill",
            defaultPrice: Money(amount: Decimal(string: "10.99")!, currencyCode: "USD"),
            defaultBillingCycle: .monthly
        ),
        PopularService(
            id: deterministicID("amazon-prime"),
            name: "Amazon Prime",
            category: .entertainment,
            brandColorHex: "#00A8E1",
            iconSymbolName: "shippingbox.fill",
            defaultPrice: Money(amount: Decimal(string: "14.99")!, currencyCode: "USD"),
            defaultBillingCycle: .monthly
        ),
        PopularService(
            id: deterministicID("dropbox"),
            name: "Dropbox",
            category: .storage,
            brandColorHex: "#0061FF",
            iconSymbolName: "externaldrive.fill",
            defaultPrice: Money(amount: Decimal(string: "11.99")!, currencyCode: "USD"),
            defaultBillingCycle: .monthly
        )
    ]

    private static func deterministicID(_ slug: String) -> UUID {
        var bytes = Array(slug.utf8.prefix(16))
        while bytes.count < 16 { bytes.append(0) }
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }
}
