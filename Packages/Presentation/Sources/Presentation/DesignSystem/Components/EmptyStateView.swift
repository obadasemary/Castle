import SwiftUI

public struct EmptyStateView: View {
    private let symbolName: String
    private let title: String
    private let message: String
    private let actionTitle: String?
    private let action: (@MainActor () -> Void)?

    public init(
        symbolName: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (@MainActor () -> Void)? = nil
    ) {
        self.symbolName = symbolName
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: symbolName)
                .font(.system(size: 44, weight: .regular))
                .foregroundStyle(Color.castleAccentBrand)
            Text(title)
                .font(CastleFont.title)
                .foregroundStyle(Color.castleTextPrimary)
                .multilineTextAlignment(.center)
            Text(message)
                .font(CastleFont.body)
                .foregroundStyle(Color.castleTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(CastleFont.bodyEmphasized)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.castleAccentBrand, in: Capsule())
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .padding(.top, Spacing.sm)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xl)
    }
}
