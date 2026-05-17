import SwiftUI

public struct DashboardPlaceholderView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            EmptyStateView(
                symbolName: "square.grid.2x2.fill",
                title: "Dashboard",
                message: "Spending summary, budget progress, and upcoming payments will live here once subscriptions land in the next PR."
            )
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    DashboardPlaceholderView()
}
