import Foundation
import SwiftData

@Model
final class SubscriptionModel {
    @Attribute(.unique) var id: UUID
    var serviceName: String
    var categoryRaw: String
    var priceAmount: Decimal
    var currencyCode: String
    var billingCycleRaw: String
    var billingCycleCustomDays: Int?
    var nextBillingDate: Date
    var statusRaw: String
    var reminderOffset: Int?
    var brandColorHex: String
    var iconSymbolName: String
    var notes: String
    var startDate: Date

    init(
        id: UUID,
        serviceName: String,
        categoryRaw: String,
        priceAmount: Decimal,
        currencyCode: String,
        billingCycleRaw: String,
        billingCycleCustomDays: Int?,
        nextBillingDate: Date,
        statusRaw: String,
        reminderOffset: Int?,
        brandColorHex: String,
        iconSymbolName: String,
        notes: String,
        startDate: Date
    ) {
        self.id = id
        self.serviceName = serviceName
        self.categoryRaw = categoryRaw
        self.priceAmount = priceAmount
        self.currencyCode = currencyCode
        self.billingCycleRaw = billingCycleRaw
        self.billingCycleCustomDays = billingCycleCustomDays
        self.nextBillingDate = nextBillingDate
        self.statusRaw = statusRaw
        self.reminderOffset = reminderOffset
        self.brandColorHex = brandColorHex
        self.iconSymbolName = iconSymbolName
        self.notes = notes
        self.startDate = startDate
    }
}
