import SwiftUI

public struct InsightCard: View {
    private let insight: String

    public init(insight: String) {
        self.insight = insight
    }

    public var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.castleAccentBrand)
                .padding(Spacing.sm)
                .background(
                    Circle().fill(Color.castleAccentBrandMuted)
                )
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("Insight")
                    .font(CastleFont.captionEmphasized)
                    .foregroundStyle(Color.castleTextSecondary)
                Text(insight)
                    .font(CastleFont.bodyEmphasized)
                    .foregroundStyle(Color.castleTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                .fill(Color.castleSurfaceElevated)
        )
    }
}
