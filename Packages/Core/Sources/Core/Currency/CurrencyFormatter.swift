import Foundation

public struct CurrencyFormatter: Sendable {
    private let locale: Locale

    public init(locale: Locale = .current) {
        self.locale = locale
    }

    public func string(from money: Money) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = money.currencyCode
        formatter.locale = locale
        return formatter.string(from: money.amount as NSDecimalNumber) ?? "\(money.currencyCode) \(money.amount)"
    }
}
