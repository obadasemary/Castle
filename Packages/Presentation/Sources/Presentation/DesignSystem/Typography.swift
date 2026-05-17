import SwiftUI

public enum CastleFont {
    public static let display: Font = .system(size: 34, weight: .bold, design: .rounded)
    public static let titleLarge: Font = .system(size: 28, weight: .bold, design: .rounded)
    public static let title: Font = .system(size: 22, weight: .semibold, design: .rounded)
    public static let headline: Font = .system(size: 17, weight: .semibold)
    public static let body: Font = .system(size: 15, weight: .regular)
    public static let bodyEmphasized: Font = .system(size: 15, weight: .semibold)
    public static let caption: Font = .system(size: 13, weight: .regular)
    public static let captionEmphasized: Font = .system(size: 13, weight: .semibold)
    public static let micro: Font = .system(size: 11, weight: .medium)
}

public extension View {
    func castleFont(_ font: Font) -> some View {
        self.font(font)
    }
}
