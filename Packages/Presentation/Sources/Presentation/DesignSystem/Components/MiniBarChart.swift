import SwiftUI

public struct MiniBarChart: View {
    public struct Bar: Identifiable, Hashable {
        public let id: String
        public let value: Double
        public let label: String

        public init(id: String, value: Double, label: String) {
            self.id = id
            self.value = value
            self.label = label
        }
    }

    private let bars: [Bar]
    private let tint: Color
    private let maxValueOverride: Double?

    public init(
        bars: [Bar],
        tint: Color = .castleAccentBrand,
        maxValue: Double? = nil
    ) {
        self.bars = bars
        self.tint = tint
        self.maxValueOverride = maxValue
    }

    public var body: some View {
        let normalizer = maxValueOverride ?? bars.map(\.value).max() ?? 1
        let safeNormalizer = normalizer == 0 ? 1 : normalizer
        HStack(alignment: .bottom, spacing: Spacing.sm) {
            ForEach(bars) { bar in
                VStack(spacing: Spacing.xs) {
                    GeometryReader { proxy in
                        let normalized = max(0.02, bar.value / safeNormalizer)
                        VStack {
                            Spacer(minLength: 0)
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(tint.opacity(0.85))
                                .frame(height: proxy.size.height * normalized)
                        }
                    }
                    Text(bar.label)
                        .font(CastleFont.micro)
                        .foregroundStyle(Color.castleTextSecondary)
                }
            }
        }
    }
}
