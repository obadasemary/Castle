import Foundation
import Core
import Domain

enum PaymentRecordMapper {
    static func toDomain(_ model: PaymentRecordModel) -> PaymentRecord {
        PaymentRecord(
            id: model.id,
            subscriptionID: model.subscriptionID,
            subscriptionName: model.subscriptionName,
            amount: Money(amount: model.amountValue, currencyCode: model.amountCurrencyCode),
            date: model.date
        )
    }

    static func makeModel(from record: PaymentRecord) -> PaymentRecordModel {
        PaymentRecordModel(
            id: record.id,
            subscriptionID: record.subscriptionID,
            subscriptionName: record.subscriptionName,
            amountValue: record.amount.amount,
            amountCurrencyCode: record.amount.currencyCode,
            date: record.date
        )
    }
}
