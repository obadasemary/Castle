import Testing
@testable import Core

@Suite("Money")
struct MoneyTests {
    @Test("Zero factory sets amount to 0")
    func zeroFactory() {
        let m = Money.zero(currencyCode: "EUR")
        #expect(m.amount == 0)
        #expect(m.currencyCode == "EUR")
    }

    @Test("Addition preserves currency and sums amounts")
    func addition() {
        let a = Money(amount: 10, currencyCode: "USD")
        let b = Money(amount: 5.50, currencyCode: "USD")
        let result = a + b
        #expect(result.amount == 15.50)
        #expect(result.currencyCode == "USD")
    }

    @Test("Comparable less-than compares amounts")
    func comparable() {
        let cheap = Money(amount: 5, currencyCode: "USD")
        let expensive = Money(amount: 20, currencyCode: "USD")
        #expect(cheap < expensive)
        #expect(expensive > cheap)
    }

    @Test("Equal amounts and currency codes are equal")
    func equality() {
        let a = Money(amount: 9.99, currencyCode: "USD")
        let b = Money(amount: 9.99, currencyCode: "USD")
        #expect(a == b)
    }

    @Test("Different currency codes are not equal")
    func differentCurrencies() {
        let usd = Money(amount: 10, currencyCode: "USD")
        let eur = Money(amount: 10, currencyCode: "EUR")
        #expect(usd != eur)
    }
}
