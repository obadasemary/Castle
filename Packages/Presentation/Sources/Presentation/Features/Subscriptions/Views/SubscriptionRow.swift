import SwiftUI
import Core
import Domain

public struct SubscriptionRow: View {
    private let subscription: Subscription
    private let formatter: CurrencyFormatter

    public init(subscription: Subscription, formatter: CurrencyFormatter = CurrencyFormatter()) {
        self.subscription = subscription
        self.formatter = formatter
    }

    public var body: some View {
        HStack(spacing: Spacing.md) {
            BrandIcon(
                symbolName: subscription.iconSymbolName,
                brandColorHex: subscription.brandColorHex,
                size: .medium
            )
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(subscription.serviceName)
                    .font(CastleFont.bodyEmphasized)
                    .foregroundStyle(Color.castleTextPrimary)
                HStack(spacing: Spacing.xs) {
                    Text(subscription.category.displayName)
                        .font(CastleFont.caption)
                        .foregroundStyle(Color.castleTextSecondary)
                    Text("•")
                        .font(CastleFont.caption)
                        .foregroundStyle(Color.castleTextSecondary)
                    Text(billingCycleLabel)
                        .font(CastleFont.caption)
                        .foregroundStyle(Color.castleTextSecondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                Text(formatter.string(from: subscription.price))
                    .font(CastleFont.bodyEmphasized)
                    .foregroundStyle(Color.castleTextPrimary)
                StatusPill(statusPillKind)
            }
        }
        .padding(.vertical, Spacing.xs)
        .contentShape(Rectangle())
    }

    private var billingCycleLabel: String {
        switch subscription.billingCycle {
        case .monthly: "Monthly"
        case .annual: "Annual"
        case .custom(let days): "Every \(days)d"
        }
    }

    private var statusPillKind: StatusPill.Status {
        switch subscription.status {
        case .archived: .archived
        case .active: .active
        }
    }
}
