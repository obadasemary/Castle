import SwiftUI

public struct StatusPill: View {
    public enum Status: Sendable {
        case active
        case expiringSoon
        case archived

        var label: String {
            switch self {
            case .active: "Active"
            case .expiringSoon: "Expiring Soon"
            case .archived: "Archived"
            }
        }

        var tint: Color {
            switch self {
            case .active: .castleStatusActive
            case .expiringSoon: .castleStatusExpiring
            case .archived: .castleStatusArchived
            }
        }
    }

    private let status: Status

    public init(_ status: Status) {
        self.status = status
    }

    public var body: some View {
        Text(status.label)
            .font(CastleFont.micro)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(status.tint.opacity(0.18), in: Capsule())
            .foregroundStyle(status.tint)
    }
}
