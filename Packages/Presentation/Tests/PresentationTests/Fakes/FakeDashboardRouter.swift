import Foundation
@testable import Presentation

@MainActor
final class FakeDashboardRouter: DashboardRouter {
    var showSubscriptionsCallCount = 0
    var showSubscriptionDetailIDs: [UUID] = []
    var showAnalyticsCallCount = 0

    func showSubscriptions() {
        showSubscriptionsCallCount += 1
    }

    func showSubscriptionDetail(_ id: UUID) {
        showSubscriptionDetailIDs.append(id)
    }

    func showAnalytics() {
        showAnalyticsCallCount += 1
    }
}
