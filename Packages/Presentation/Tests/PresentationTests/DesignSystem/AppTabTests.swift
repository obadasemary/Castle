import Testing
@testable import Presentation

@Suite("AppTab metadata")
struct AppTabTests {
    @Test("has four tabs in dashboard-first order")
    func hasFourTabsInOrder() {
        #expect(AppTab.allCases == [.dashboard, .subscriptions, .analytics, .settings])
    }

    @Test("every tab has a non-empty title and SF symbol")
    func metadataIsPopulated() {
        for tab in AppTab.allCases {
            #expect(tab.title.isEmpty == false)
            #expect(tab.symbolName.isEmpty == false)
        }
    }
}
