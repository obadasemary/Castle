import Foundation
import Core

public struct ActivityEvent: Identifiable, Hashable, Codable, Sendable {
    public enum EventType: Hashable, Codable, Sendable {
        case paid(amount: Money)
        case added
        case archived
        case priceChanged(oldPrice: Money, newPrice: Money)
    }

    public let id: UUID
    public let subscriptionID: UUID
    public let subscriptionName: String
    public let type: EventType
    public let date: Date

    public init(
        id: UUID = UUID(),
        subscriptionID: UUID,
        subscriptionName: String,
        type: EventType,
        date: Date
    ) {
        self.id = id
        self.subscriptionID = subscriptionID
        self.subscriptionName = subscriptionName
        self.type = type
        self.date = date
    }
}
