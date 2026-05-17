import Foundation
import Core

public struct SubscriptionInput: Sendable {
    public var serviceName: String
    public var price: Decimal
    public var currencyCode: String
    public var billingCycle: BillingCycle
    public var category: Category
    public var nextBillingDate: Date
    public var iconSymbolName: String
    public var brandColorHex: String
    public var reminderOffset: Int?
    public var notes: String

    public init(
        serviceName: String = "",
        price: Decimal = 0,
        currencyCode: String = "USD",
        billingCycle: BillingCycle = .monthly,
        category: Category = .other,
        nextBillingDate: Date = Date(),
        iconSymbolName: String = "creditcard",
        brandColorHex: String = "#6C757D",
        reminderOffset: Int? = nil,
        notes: String = ""
    ) {
        self.serviceName = serviceName
        self.price = price
        self.currencyCode = currencyCode
        self.billingCycle = billingCycle
        self.category = category
        self.nextBillingDate = nextBillingDate
        self.iconSymbolName = iconSymbolName
        self.brandColorHex = brandColorHex
        self.reminderOffset = reminderOffset
        self.notes = notes
    }
}
