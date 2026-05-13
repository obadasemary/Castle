import SwiftUI

public struct BrandIcon: View {
    public enum Size {
        case small, medium, large

        var dimension: CGFloat {
            switch self {
            case .small: 32
            case .medium: 44
            case .large: 64
            }
        }

        var symbolFont: Font {
            switch self {
            case .small: .system(size: 16, weight: .semibold)
            case .medium: .system(size: 22, weight: .semibold)
            case .large: .system(size: 30, weight: .semibold)
            }
        }
    }

    private let symbolName: String
    private let brandColorHex: String
    private let size: Size

    public init(symbolName: String, brandColorHex: String, size: Size = .medium) {
        self.symbolName = symbolName
        self.brandColorHex = brandColorHex
        self.size = size
    }

    public var body: some View {
        let brandColor = Color(brandHex: brandColorHex)
        Circle()
            .fill(brandColor.opacity(0.18))
            .frame(width: size.dimension, height: size.dimension)
            .overlay {
                Image(systemName: symbolName)
                    .font(size.symbolFont)
                    .foregroundStyle(brandColor)
            }
    }
}
