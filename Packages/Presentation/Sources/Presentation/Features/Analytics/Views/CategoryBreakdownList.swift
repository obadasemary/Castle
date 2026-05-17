import SwiftUI
import Core
import Domain

public struct CategoryBreakdownList: View {
    private let breakdown: [CategorySpend]
    private let formatter: CurrencyFormatter

    public init(
        breakdown: [CategorySpend],
        formatter: CurrencyFormatter = CurrencyFormatter()
    ) {
        self.breakdown = breakdown
        self.formatter = formatter
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Categories")
            VStack(spacing: 0) {
                ForEach(Array(breakdown.enumerated()), id: \.element.category) { index, item in
                    row(item)
                    if index != breakdown.count - 1 {
                        Divider().padding(.leading, Spacing.xxl)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                    .fill(Color.castleSurfaceElevated)
            )
        }
    }

    private func row(_ item: CategorySpend) -> some View {
        HStack(spacing: Spacing.md) {
            Circle()
                .fill(CategoryColor.color(for: item.category))
                .frame(width: 12, height: 12)
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(item.category.displayName)
                    .font(CastleFont.bodyEmphasized)
                    .foregroundStyle(Color.castleTextPrimary)
                Text("\(Int(item.percentage.rounded()))% of monthly")
                    .font(CastleFont.caption)
                    .foregroundStyle(Color.castleTextSecondary)
            }
            Spacer()
            Text(formatter.string(from: item.total))
                .font(CastleFont.bodyEmphasized)
                .foregroundStyle(Color.castleTextPrimary)
        }
        .padding(Spacing.md)
    }
}
