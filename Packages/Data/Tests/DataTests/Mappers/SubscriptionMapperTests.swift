import Testing
import Foundation
import Core
import Domain
@testable import Data

@Suite("SubscriptionMapper")
struct SubscriptionMapperTests {
    @Test("makeModel then toDomain preserves every field")
    func roundTripPreservesEveryField() {
        let original = Subscription(
            id: UUID(),
            serviceName: "Netflix",
            category: .entertainment,
            price: Money(amount: Decimal(string: "15.99")!, currencyCode: "USD"),
            billingCycle: .annual,
            nextBillingDate: Date(timeIntervalSince1970: 1_750_000_000),
            status: .active,
            reminderOffset: 3,
            brandColorHex: "#E50914",
            iconSymbolName: "play.tv.fill",
            notes: "Family plan",
            startDate: Date(timeIntervalSince1970: 1_700_000_000)
        )

        let model = SubscriptionMapper.makeModel(from: original)
        let mapped = SubscriptionMapper.toDomain(model)

        #expect(mapped == original)
    }

    @Test("apply mutates an existing model in place")
    func applyMutatesInPlace() {
        let originalID = UUID()
        let original = Subscription(
            id: originalID,
            serviceName: "Netflix",
            category: .entertainment,
            price: Money(amount: Decimal(string: "15.99")!, currencyCode: "USD"),
            billingCycle: .monthly,
            nextBillingDate: Date(timeIntervalSince1970: 1_750_000_000)
        )
        let model = SubscriptionMapper.makeModel(from: original)

        let updated = Subscription(
            id: originalID,
            serviceName: "Netflix Premium",
            category: .entertainment,
            price: Money(amount: Decimal(string: "22.99")!, currencyCode: "USD"),
            billingCycle: .annual,
            nextBillingDate: Date(timeIntervalSince1970: 1_780_000_000),
            status: .archived,
            reminderOffset: 5
        )
        SubscriptionMapper.apply(updated, to: model)

        let mapped = SubscriptionMapper.toDomain(model)
        #expect(mapped == updated)
        #expect(model.id == originalID)
    }

    @Test("billingCycle storage round-trips monthly, annual, and custom")
    func billingCycleStorageRoundTrips() {
        for cycle in [BillingCycle.monthly, .annual, .custom(days: 14)] {
            let encoded = BillingCycleStorage.encode(cycle)
            let decoded = BillingCycleStorage.decode(raw: encoded.raw, customDays: encoded.customDays)
            #expect(decoded == cycle, "round-trip failed for \(cycle)")
        }
    }
}
