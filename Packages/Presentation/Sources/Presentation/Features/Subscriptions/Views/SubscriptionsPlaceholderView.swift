import SwiftUI

public struct SubscriptionsPlaceholderView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            EmptyStateView(
                symbolName: "creditcard.fill",
                title: "No subscriptions yet",
                message: "PR 5 will wire up the active list, detail view, and the add-from-catalog flow.",
                actionTitle: "Add subscription",
                action: {}
            )
            .navigationTitle("Subscriptions")
        }
    }
}

#Preview {
    SubscriptionsPlaceholderView()
}
