import SwiftUI
import Core
import Domain

public struct PaymentHistoryList: View {
    private let payments: [PaymentRecord]
    private let formatter: CurrencyFormatter

    public init(payments: [PaymentRecord], formatter: CurrencyFormatter = CurrencyFormatter()) {
        self.payments = payments
        self.formatter = formatter
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Payment History")
            if payments.isEmpty {
                Text("No payments recorded yet.")
                    .font(CastleFont.caption)
                    .foregroundStyle(Color.castleTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, Spacing.sm)
            } else {
                ForEach(payments) { payment in
                    HStack {
                        Text(payment.date, style: .date)
                            .font(CastleFont.body)
                            .foregroundStyle(Color.castleTextPrimary)
                        Spacer()
                        Text(formatter.string(from: payment.amount))
                            .font(CastleFont.bodyEmphasized)
                            .foregroundStyle(Color.castleTextPrimary)
                    }
                    .padding(.vertical, Spacing.xs)
                    if payment.id != payments.last?.id {
                        Divider()
                    }
                }
            }
        }
    }
}
