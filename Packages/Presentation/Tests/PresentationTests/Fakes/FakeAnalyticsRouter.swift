import Domain
@testable import Presentation

@MainActor
final class FakeAnalyticsRouter: AnalyticsRouter {
    var showCategoryDetailCalls: [Domain.Category] = []

    func showCategoryDetail(_ category: Domain.Category) {
        showCategoryDetailCalls.append(category)
    }
}
