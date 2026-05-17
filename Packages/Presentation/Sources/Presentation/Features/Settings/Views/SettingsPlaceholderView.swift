import SwiftUI

public struct SettingsPlaceholderView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            EmptyStateView(
                symbolName: "gearshape.fill",
                title: "Settings",
                message: "Currency, appearance, and notification preferences land in PR 8."
            )
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsPlaceholderView()
}
