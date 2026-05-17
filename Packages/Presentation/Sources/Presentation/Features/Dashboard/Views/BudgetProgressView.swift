import SwiftUI
import Core
import Domain

public struct BudgetProgressView: View {
    private let progress: BudgetProgress
    private let formatter: CurrencyFormatter

    public init(
        progress: BudgetProgress,
        formatter: CurrencyFormatter = CurrencyFormatter()
    ) {
        self.progress = progress
        self.formatter = formatter
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Monthly budget")
                    .font(CastleFont.headline)
                    .foregroundStyle(Color.castleTextPrimary)
                Spacer()
                Text(percentLabel)
                    .font(CastleFont.captionEmphasized)
                    .foregroundStyle(progress.isOverBudget ? Color.castleStatusExpiring : Color.castleTextSecondary)
            }
            ProgressBar(
                progress: progress.fraction,
                tint: progress.isOverBudget ? Color.castleStatusExpiring : Color.castleAccentBrand
            )
            HStack {
                Text("\(formatter.string(from: progress.spent)) spent")
                    .font(CastleFont.caption)
                    .foregroundStyle(Color.castleTextSecondary)
                Spacer()
                Text("of \(formatter.string(from: progress.budget))")
                    .font(CastleFont.caption)
                    .foregroundStyle(Color.castleTextSecondary)
            }
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                .fill(Color.castleSurfaceElevated)
        )
    }

    private var percentLabel: String {
        let pct = Int((progress.fraction * 100).rounded())
        return progress.isOverBudget ? "Over budget" : "\(pct)%"
    }
}
