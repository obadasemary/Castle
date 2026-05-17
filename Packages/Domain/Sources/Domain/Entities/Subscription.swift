import Foundation
import Core

public struct Subscription: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public var serviceName: String
    public var category: Category
    public var price: Money
    public var billingCycle: BillingCycle
    public var nextBillingDate: Date
    public var status: Status
    public var reminderOffset: Int?      // days before billing to fire local notification
    public var brandColorHex: String
    public var iconSymbolName: String
    public var notes: String
    public var startDate: Date

    public enum Status: String, Hashable, Codable, Sendable {
        case active, archived
    }

    public init(
        id: UUID = UUID(),
        serviceName: String,
        category: Category,
        price: Money,
        billingCycle: BillingCycle,
        nextBillingDate: Date,
        status: Status = .active,
        reminderOffset: Int? = nil,
        brandColorHex: String = "#6C757D",
        iconSymbolName: String = "creditcard",
        notes: String = "",
        startDate: Date = Date()
    ) {
        self.id = id
        self.serviceName = serviceName
        self.category = category
        self.price = price
        self.billingCycle = billingCycle
        self.nextBillingDate = nextBillingDate
        self.status = status
        self.reminderOffset = reminderOffset
        self.brandColorHex = brandColorHex
        self.iconSymbolName = iconSymbolName
        self.notes = notes
        self.startDate = startDate
    }
}
