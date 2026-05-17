import SwiftUI
import Core
import Domain

public struct ServiceCell: View {
    private let service: PopularService
    private let formatter: CurrencyFormatter

    public init(service: PopularService, formatter: CurrencyFormatter = CurrencyFormatter()) {
        self.service = service
        self.formatter = formatter
    }

    public var body: some View {
        VStack(spacing: Spacing.sm) {
            BrandIcon(
                symbolName: service.iconSymbolName,
                brandColorHex: service.brandColorHex,
                size: .medium
            )
            Text(service.name)
                .font(CastleFont.bodyEmphasized)
                .foregroundStyle(Color.castleTextPrimary)
                .lineLimit(1)
            Text(formatter.string(from: service.defaultPrice))
                .font(CastleFont.caption)
                .foregroundStyle(Color.castleTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(Color.castleSurfaceElevated, in: RoundedRectangle(cornerRadius: CornerRadius.lg))
    }
}
