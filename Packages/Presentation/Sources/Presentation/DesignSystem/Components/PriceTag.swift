import SwiftUI
import Core

public struct PriceTag: View {
    public enum Size {
        case small, medium, large

        var amountFont: Font {
            switch self {
            case .small: CastleFont.bodyEmphasized
            case .medium: CastleFont.title
            case .large: CastleFont.display
            }
        }

        var cadenceFont: Font {
            switch self {
            case .small: CastleFont.micro
            case .medium: CastleFont.caption
            case .large: CastleFont.headline
            }
        }
    }

    private let money: Money
    private let cadence: String?
    private let size: Size
    private let formatter: CurrencyFormatter

    public init(
        money: Money,
        cadence: String? = nil,
        size: Size = .medium,
        formatter: CurrencyFormatter = CurrencyFormatter()
    ) {
        self.money = money
        self.cadence = cadence
        self.size = size
        self.formatter = formatter
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
            Text(formatter.string(from: money))
                .font(size.amountFont)
                .foregroundStyle(Color.castleTextPrimary)
            if let cadence {
                Text(cadence)
                    .font(size.cadenceFont)
                    .foregroundStyle(Color.castleTextSecondary)
            }
        }
    }
}
