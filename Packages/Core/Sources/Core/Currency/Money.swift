import Foundation

public struct Money: Hashable, Codable, Sendable {
    public let amount: Decimal
    public let currencyCode: String  // ISO 4217

    public init(amount: Decimal, currencyCode: String) {
        self.amount = amount
        self.currencyCode = currencyCode
    }

    public static func zero(currencyCode: String) -> Money {
        Money(amount: 0, currencyCode: currencyCode)
    }
}

extension Money: Comparable {
    public static func < (lhs: Money, rhs: Money) -> Bool {
        lhs.amount < rhs.amount
    }
}

extension Money {
    public static func + (lhs: Money, rhs: Money) -> Money {
        precondition(lhs.currencyCode == rhs.currencyCode, "Cannot add Money with different currency codes")
        return Money(amount: lhs.amount + rhs.amount, currencyCode: lhs.currencyCode)
    }
}
