import Foundation
import SwiftData

@Model
final class UserProfileModel {
    @Attribute(.unique) var id: UUID
    var displayName: String
    var preferredCurrencyCode: String
    var monthlyBudgetAmount: Decimal?
    var monthlyBudgetCurrencyCode: String?
    var appearanceRaw: String

    init(
        id: UUID,
        displayName: String,
        preferredCurrencyCode: String,
        monthlyBudgetAmount: Decimal?,
        monthlyBudgetCurrencyCode: String?,
        appearanceRaw: String
    ) {
        self.id = id
        self.displayName = displayName
        self.preferredCurrencyCode = preferredCurrencyCode
        self.monthlyBudgetAmount = monthlyBudgetAmount
        self.monthlyBudgetCurrencyCode = monthlyBudgetCurrencyCode
        self.appearanceRaw = appearanceRaw
    }
}
