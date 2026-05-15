import SwiftUI
import Core
import Domain

public struct HeroSpendCard: View {
    private let monthlySpend: Money
    private let trend: [MonthlySpend]
    private let formatter: CurrencyFormatter

    public init(
        monthlySpend: Money,
        trend: [MonthlySpend],
        formatter: CurrencyFormatter = CurrencyFormatter()
    ) {
        self.monthlySpend = monthlySpend
        self.trend = trend
        self.formatter = formatter
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Total spend this month")
                    .font(CastleFont.caption)
                    .foregroundStyle(Color.castleTextSecondary)
                Text(formatter.string(from: monthlySpend))
                    .font(CastleFont.display)
                    .foregroundStyle(Color.castleTextPrimary)
            }
            if !trend.isEmpty {
                MiniBarChart(bars: trend.map(Self.bar(from:)))
                    .frame(height: 80)
                    .accessibilityLabel("Spending trend last \(trend.count) months")
            }
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                .fill(Color.castleSurfaceElevated)
        )
    }

    private static func bar(from spend: MonthlySpend) -> MiniBarChart.Bar {
        let value = (spend.total.amount as NSDecimalNumber).doubleValue
        let label = Self.monthLabel(month: spend.month)
        return MiniBarChart.Bar(id: "\(spend.year)-\(spend.month)", value: value, label: label)
    }

    private static func monthLabel(month: Int) -> String {
        let symbols = Calendar(identifier: .gregorian).veryShortStandaloneMonthSymbols
        guard month >= 1, month <= symbols.count else { return "" }
        return symbols[month - 1]
    }
}
