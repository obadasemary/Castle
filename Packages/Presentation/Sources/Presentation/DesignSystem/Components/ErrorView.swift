import SwiftUI

public struct ErrorView: View {
    private let title: String
    private let message: String
    private let retryTitle: String
    private let retry: (@MainActor () -> Void)?

    public init(
        title: String = "Something went wrong",
        message: String,
        retryTitle: String = "Try again",
        retry: (@MainActor () -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.retryTitle = retryTitle
        self.retry = retry
    }

    public var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.castleStatusExpiring)
            Text(title)
                .font(CastleFont.title)
                .foregroundStyle(Color.castleTextPrimary)
                .multilineTextAlignment(.center)
            Text(message)
                .font(CastleFont.body)
                .foregroundStyle(Color.castleTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
            if let retry {
                Button(action: retry) {
                    Text(retryTitle)
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
