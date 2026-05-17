import SwiftUI

public struct SubscriptionsPlaceholderView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            EmptyStateView(
                symbolName: "creditcard.fill",
                title: "Subscriptions",
                message: "Inject a SubscriptionsViewModelFactory to wire up the live list."
            )
            .navigationTitle("Subscriptions")
        }
    }
}

#Preview {
    SubscriptionsPlaceholderView()
}
