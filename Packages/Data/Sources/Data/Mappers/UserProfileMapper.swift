import Foundation
import Core
import Domain

enum UserProfileMapper {
    static func toDomain(_ model: UserProfileModel) -> UserProfile {
        let budget: Money? = {
            guard let amount = model.monthlyBudgetAmount,
                  let currency = model.monthlyBudgetCurrencyCode else { return nil }
            return Money(amount: amount, currencyCode: currency)
        }()
        return UserProfile(
            id: model.id,
            displayName: model.displayName,
            preferredCurrencyCode: model.preferredCurrencyCode,
            monthlyBudget: budget,
            appearance: UserProfile.Appearance(rawValue: model.appearanceRaw) ?? .system
        )
    }

    static func makeModel(from profile: UserProfile) -> UserProfileModel {
        UserProfileModel(
            id: profile.id,
            displayName: profile.displayName,
            preferredCurrencyCode: profile.preferredCurrencyCode,
            monthlyBudgetAmount: profile.monthlyBudget?.amount,
            monthlyBudgetCurrencyCode: profile.monthlyBudget?.currencyCode,
            appearanceRaw: profile.appearance.rawValue
        )
    }

    static func apply(_ profile: UserProfile, to model: UserProfileModel) {
        model.displayName = profile.displayName
        model.preferredCurrencyCode = profile.preferredCurrencyCode
        model.monthlyBudgetAmount = profile.monthlyBudget?.amount
        model.monthlyBudgetCurrencyCode = profile.monthlyBudget?.currencyCode
        model.appearanceRaw = profile.appearance.rawValue
    }
}
