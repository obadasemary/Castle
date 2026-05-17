import Foundation
@testable import Presentation

@MainActor
final class FakeSettingsRouter: SettingsRouter {
    var openSystemSettingsCallCount = 0

    func openSystemSettings() {
        openSystemSettingsCallCount += 1
    }
}
