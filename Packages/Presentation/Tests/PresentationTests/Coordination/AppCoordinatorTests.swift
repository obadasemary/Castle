import Foundation
import Testing
import Domain
@testable import Presentation

@Suite("AppCoordinator")
@MainActor
struct AppCoordinatorTests {
    @Test("default tab is dashboard")
    func defaultTabIsDashboard() {
        let coordinator = AppCoordinator()
        #expect(coordinator.selectedTab == .dashboard)
        #expect(coordinator.subscriptionsPath.isEmpty)
        #expect(coordinator.isPresentingAddSubscription == false)
    }

    @Test("showSubscriptions switches the active tab")
    func showSubscriptionsSwitchesTab() {
        let coordinator = AppCoordinator()
        coordinator.showSubscriptions()
        #expect(coordinator.selectedTab == .subscriptions)
    }

    @Test("showSubscriptionDetail navigates to detail and switches tabs")
    func showSubscriptionDetailSwitchesAndPushes() {
        let coordinator = AppCoordinator()
        let id = UUID()
        coordinator.showSubscriptionDetail(id)
        #expect(coordinator.selectedTab == .subscriptions)
        #expect(coordinator.subscriptionsPath.count == 1)
    }

    @Test("presentAdd toggles sheet flag")
    func presentAddTogglesFlag() {
        let coordinator = AppCoordinator()
        coordinator.presentAdd()
        #expect(coordinator.isPresentingAddSubscription)
    }

    @Test("dismiss pops the stack when there's a detail on top")
    func dismissPopsDetail() {
        let coordinator = AppCoordinator()
        coordinator.showDetail(UUID())
        #expect(coordinator.subscriptionsPath.count == 1)
        coordinator.dismiss()
        #expect(coordinator.subscriptionsPath.isEmpty)
    }

    @Test("dismiss closes the add sheet when stack is empty")
    func dismissClosesAddSheet() {
        let coordinator = AppCoordinator()
        coordinator.presentAdd()
        coordinator.dismiss()
        #expect(coordinator.isPresentingAddSubscription == false)
    }

    @Test("showCategoryDetail pushes onto analytics path")
    func showCategoryDetailPushes() {
        let coordinator = AppCoordinator()
        coordinator.showCategoryDetail(.entertainment)
        #expect(coordinator.analyticsPath.count == 1)
    }
}
