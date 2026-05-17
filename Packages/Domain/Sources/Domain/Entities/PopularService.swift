import Foundation
import Core

public struct PopularService: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public let name: String
    public let category: Category
    public let brandColorHex: String
    public let iconSymbolName: String
    public let defaultPrice: Money
    public let defaultBillingCycle: BillingCycle

    public init(
        id: UUID = UUID(),
        name: String,
        category: Category,
        brandColorHex: String,
        iconSymbolName: String,
        defaultPrice: Money,
        defaultBillingCycle: BillingCycle
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.brandColorHex = brandColorHex
        self.iconSymbolName = iconSymbolName
        self.defaultPrice = defaultPrice
        self.defaultBillingCycle = defaultBillingCycle
    }
}
