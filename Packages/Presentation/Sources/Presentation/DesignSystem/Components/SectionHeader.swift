import SwiftUI

public struct SectionHeader: View {
    private let title: String
    private let trailingTitle: String?
    private let trailingAction: (@MainActor () -> Void)?

    public init(
        _ title: String,
        trailingTitle: String? = nil,
        trailingAction: (@MainActor () -> Void)? = nil
    ) {
        self.title = title
        self.trailingTitle = trailingTitle
        self.trailingAction = trailingAction
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(CastleFont.headline)
                .foregroundStyle(Color.castleTextPrimary)
            Spacer()
            if let trailingTitle, let trailingAction {
                Button(action: trailingAction) {
                    Text(trailingTitle)
                        .font(CastleFont.captionEmphasized)
                        .foregroundStyle(Color.castleAccentBrand)
                }
                .buttonStyle(.plain)
            } else if let trailingTitle {
                Text(trailingTitle)
                    .font(CastleFont.captionEmphasized)
                    .foregroundStyle(Color.castleAccentBrand)
            }
        }
    }
}
