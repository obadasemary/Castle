import Foundation
@testable import Presentation

@MainActor
final class FakeSubscriptionsRouter: SubscriptionsRouter {
    var presentAddCallCount = 0
    var showDetailIDs: [UUID] = []
    var dismissCallCount = 0

    func presentAdd() {
        presentAddCallCount += 1
    }

    func showDetail(_ id: UUID) {
        showDetailIDs.append(id)
    }

    func dismiss() {
        dismissCallCount += 1
    }
}
