import SwiftUI

public struct PermissionDeniedView: View {
    public enum Permission {
        case notifications

        var symbolName: String {
            switch self {
            case .notifications: "bell.slash.fill"
            }
        }

        var title: String {
            switch self {
            case .notifications: "Notifications are off"
            }
        }

        var message: String {
            switch self {
            case .notifications:
                "Castle needs notification access to remind you before payments. You can turn this on in Settings."
            }
        }
    }

    private let permission: Permission
    private let openSettings: (@MainActor () -> Void)?

    public init(permission: Permission, openSettings: (@MainActor () -> Void)? = nil) {
        self.permission = permission
        self.openSettings = openSettings
    }

    public var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: permission.symbolName)
                .font(.system(size: 44))
                .foregroundStyle(Color.castleStatusArchived)
            Text(permission.title)
                .font(CastleFont.title)
                .foregroundStyle(Color.castleTextPrimary)
                .multilineTextAlignment(.center)
            Text(permission.message)
                .font(CastleFont.body)
                .foregroundStyle(Color.castleTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
            if let openSettings {
                Button(action: openSettings) {
                    Text("Open Settings")
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
