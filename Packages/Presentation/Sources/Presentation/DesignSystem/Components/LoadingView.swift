import SwiftUI

public struct LoadingView: View {
    private let message: String?

    public init(message: String? = nil) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .controlSize(.large)
                .tint(Color.castleAccentBrand)
            if let message {
                Text(message)
                    .font(CastleFont.caption)
                    .foregroundStyle(Color.castleTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
