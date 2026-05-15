import SwiftUI
import Charts
import Core
import Domain

public struct MonthlyTrendsChart: View {
    private let trend: [MonthlySpend]

    public init(trend: [MonthlySpend]) {
        self.trend = trend
    }

    public var body: some View {
        Chart(trend, id: \.self) { item in
            BarMark(
                x: .value("Month", Self.label(for: item)),
                y: .value("Spend", (item.total.amount as NSDecimalNumber).doubleValue)
            )
            .cornerRadius(4)
            .foregroundStyle(Color.castleAccentBrand)
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .font(CastleFont.micro)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                AxisValueLabel()
                    .font(CastleFont.micro)
            }
        }
        .frame(height: 180)
        .accessibilityLabel("Monthly spending trend")
    }

    private static func label(for spend: MonthlySpend) -> String {
        let symbols = Calendar(identifier: .gregorian).veryShortStandaloneMonthSymbols
        guard spend.month >= 1, spend.month <= symbols.count else { return "" }
        return symbols[spend.month - 1]
    }
}
