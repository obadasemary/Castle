import Foundation
import SwiftData

@Model
final class PaymentRecordModel {
    @Attribute(.unique) var id: UUID
    var subscriptionID: UUID
    var subscriptionName: String
    var amountValue: Decimal
    var amountCurrencyCode: String
    var date: Date

    init(
        id: UUID,
        subscriptionID: UUID,
        subscriptionName: String,
        amountValue: Decimal,
        amountCurrencyCode: String,
        date: Date
    ) {
        self.id = id
        self.subscriptionID = subscriptionID
        self.subscriptionName = subscriptionName
        self.amountValue = amountValue
        self.amountCurrencyCode = amountCurrencyCode
        self.date = date
    }
}
