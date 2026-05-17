import SwiftUI
import Core
import Domain

public struct UpcomingPaymentsCarousel: View {
    private let payments: [Subscription]
    private let onSelect: (UUID) -> Void
    private let formatter: CurrencyFormatter
    private let dateFormatter: DateFormatter

    public init(
        payments: [Subscription],
        onSelect: @escaping (UUID) -> Void,
        formatter: CurrencyFormatter = CurrencyFormatter()
    ) {
        self.payments = payments
        self.onSelect = onSelect
        self.formatter = formatter
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        self.dateFormatter = df
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Upcoming")
            if payments.isEmpty {
                Text("No payments due in the next 30 days.")
                    .font(CastleFont.caption)
                    .foregroundStyle(Color.castleTextSecondary)
                    .padding(.vertical, Spacing.md)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(payments) { payment in
                            Button {
                                onSelect(payment.id)
                            } label: {
                                card(payment)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                }
                .padding(.horizontal, -Spacing.lg)
            }
        }
    }

    private func card(_ subscription: Subscription) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            BrandIcon(
                symbolName: subscription.iconSymbolName,
                brandColorHex: subscription.brandColorHex,
                size: .small
            )
            Text(subscription.serviceName)
                .font(CastleFont.bodyEmphasized)
                .foregroundStyle(Color.castleTextPrimary)
                .lineLimit(1)
            Text(formatter.string(from: subscription.price))
                .font(CastleFont.headline)
                .foregroundStyle(Color.castleTextPrimary)
            Text(dateFormatter.string(from: subscription.nextBillingDate))
                .font(CastleFont.caption)
                .foregroundStyle(Color.castleTextSecondary)
        }
        .padding(Spacing.md)
        .frame(width: 160, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                .fill(Color.castleSurfaceElevated)
        )
    }
}
