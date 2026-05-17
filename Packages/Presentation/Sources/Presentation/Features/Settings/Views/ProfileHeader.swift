import SwiftUI

public struct ProfileHeader: View {
    @Binding private var displayName: String
    private let preferredCurrencyCode: String

    public init(displayName: Binding<String>, preferredCurrencyCode: String) {
        _displayName = displayName
        self.preferredCurrencyCode = preferredCurrencyCode
    }

    public var body: some View {
        HStack(spacing: Spacing.lg) {
            ZStack {
                Circle()
                    .fill(Color.castleAccentBrandMuted)
                Text(initial)
                    .font(CastleFont.titleLarge)
                    .foregroundStyle(Color.castleAccentBrand)
            }
            .frame(width: 64, height: 64)
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                TextField("Your name", text: $displayName)
                    .font(CastleFont.title)
                    .textFieldStyle(.plain)
                    #if os(iOS)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(false)
                    #endif
                Text("Tracking in \(preferredCurrencyCode)")
                    .font(CastleFont.caption)
                    .foregroundStyle(Color.castleTextSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, Spacing.sm)
    }

    private var initial: String {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return "?" }
        return String(first).uppercased()
    }
}
