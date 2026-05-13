import SwiftUI

public struct AnalyticsPlaceholderView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            EmptyStateView(
                symbolName: "chart.pie.fill",
                title: "Analytics",
                message: "Category donut chart, monthly trends, and the insight card land in PR 7."
            )
            .navigationTitle("Analytics")
        }
    }
}

#Preview {
    AnalyticsPlaceholderView()
}
