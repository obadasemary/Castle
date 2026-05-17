import Foundation
import Core

public struct PaymentRecord: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public let subscriptionID: UUID
    public let subscriptionName: String  // denormalised — preserves history if subscription is renamed
    public let amount: Money
    public let date: Date

    public init(
        id: UUID = UUID(),
        subscriptionID: UUID,
        subscriptionName: String,
        amount: Money,
        date: Date
    ) {
        self.id = id
        self.subscriptionID = subscriptionID
        self.subscriptionName = subscriptionName
        self.amount = amount
        self.date = date
    }
}
