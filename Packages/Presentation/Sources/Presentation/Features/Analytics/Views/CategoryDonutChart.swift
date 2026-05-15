import SwiftUI
import Charts
import Core
import Domain

public struct CategoryDonutChart: View {
    private let breakdown: [CategorySpend]
    private let totalLabel: String

    public init(breakdown: [CategorySpend], totalLabel: String) {
        self.breakdown = breakdown
        self.totalLabel = totalLabel
    }

    public var body: some View {
        Chart(breakdown, id: \.category) { slice in
            SectorMark(
                angle: .value("Spend", (slice.total.amount as NSDecimalNumber).doubleValue),
                innerRadius: .ratio(0.62),
                angularInset: 1.5
            )
            .cornerRadius(4)
            .foregroundStyle(CategoryColor.color(for: slice.category))
        }
        .chartLegend(.hidden)
        .frame(height: 220)
        .overlay {
            VStack(spacing: Spacing.xxs) {
                Text("This month")
                    .font(CastleFont.caption)
                    .foregroundStyle(Color.castleTextSecondary)
                Text(totalLabel)
                    .font(CastleFont.title)
                    .foregroundStyle(Color.castleTextPrimary)
            }
        }
        .accessibilityLabel("Category breakdown donut chart")
    }
}
