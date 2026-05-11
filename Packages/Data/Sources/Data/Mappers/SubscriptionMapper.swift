import Foundation
import Core
import Domain

enum SubscriptionMapper {
    static func toDomain(_ model: SubscriptionModel) -> Subscription {
        Subscription(
            id: model.id,
            serviceName: model.serviceName,
            category: Category(rawValue: model.categoryRaw) ?? .other,
            price: Money(amount: model.priceAmount, currencyCode: model.currencyCode),
            billingCycle: BillingCycleStorage.decode(
                raw: model.billingCycleRaw,
                customDays: model.billingCycleCustomDays
            ),
            nextBillingDate: model.nextBillingDate,
            status: Subscription.Status(rawValue: model.statusRaw) ?? .active,
            reminderOffset: model.reminderOffset,
            brandColorHex: model.brandColorHex,
            iconSymbolName: model.iconSymbolName,
            notes: model.notes,
            startDate: model.startDate
        )
    }

    static func makeModel(from subscription: Subscription) -> SubscriptionModel {
        let cycle = BillingCycleStorage.encode(subscription.billingCycle)
        return SubscriptionModel(
            id: subscription.id,
            serviceName: subscription.serviceName,
            categoryRaw: subscription.category.rawValue,
            priceAmount: subscription.price.amount,
            currencyCode: subscription.price.currencyCode,
            billingCycleRaw: cycle.raw,
            billingCycleCustomDays: cycle.customDays,
            nextBillingDate: subscription.nextBillingDate,
            statusRaw: subscription.status.rawValue,
            reminderOffset: subscription.reminderOffset,
            brandColorHex: subscription.brandColorHex,
            iconSymbolName: subscription.iconSymbolName,
            notes: subscription.notes,
            startDate: subscription.startDate
        )
    }

    static func apply(_ subscription: Subscription, to model: SubscriptionModel) {
        let cycle = BillingCycleStorage.encode(subscription.billingCycle)
        model.serviceName = subscription.serviceName
        model.categoryRaw = subscription.category.rawValue
        model.priceAmount = subscription.price.amount
        model.currencyCode = subscription.price.currencyCode
        model.billingCycleRaw = cycle.raw
        model.billingCycleCustomDays = cycle.customDays
        model.nextBillingDate = subscription.nextBillingDate
        model.statusRaw = subscription.status.rawValue
        model.reminderOffset = subscription.reminderOffset
        model.brandColorHex = subscription.brandColorHex
        model.iconSymbolName = subscription.iconSymbolName
        model.notes = subscription.notes
        model.startDate = subscription.startDate
    }
}
