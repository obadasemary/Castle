import Foundation
import Testing
import Core
import Domain
@testable import Presentation

@Suite("AddSubscriptionViewModel")
@MainActor
struct AddSubscriptionViewModelTests {
    private func makeViewModel(
        catalog: FakePopularServicesCatalog = FakePopularServicesCatalog(),
        clockNow: Date = Date(timeIntervalSince1970: 1_700_000_000),
        router: FakeSubscriptionsRouter? = nil
    ) -> (AddSubscriptionViewModel, FakeSubscriptionRepository, FakeReminderScheduling) {
        let repo = FakeSubscriptionRepository()
        let scheduling = FakeReminderScheduling()
        let clock = FakeClock(now: clockNow)
        let calendar = FakeCalendarProvider()
        let vm = AddSubscriptionViewModel(
            listPopular: ListPopularServicesUseCase(catalog: catalog),
            validate: ValidateSubscriptionInputUseCase(clock: clock),
            suggestNextDate: SuggestNextBillingDateUseCase(clock: clock, calendarProvider: calendar),
            addUseCase: AddSubscriptionUseCase(repository: repo, reminderScheduling: scheduling),
            router: router
        )
        return (vm, repo, scheduling)
    }

    @Test("init seeds nextBillingDate via suggestion")
    func initSeedsBillingDate() {
        let (vm, _, _) = makeViewModel()
        #expect(vm.input.nextBillingDate > Date(timeIntervalSince1970: 1_700_000_000))
    }

    @Test("loadCatalog populates loaded state")
    func loadCatalogPopulates() async {
        let (vm, _, _) = makeViewModel()
        await vm.loadCatalog()
        #expect(vm.popularServices.count == FakePopularServicesCatalog.defaultServices.count)
    }

    @Test("search filters catalog")
    func searchFilters() async {
        let (vm, _, _) = makeViewModel()
        await vm.loadCatalog()
        await vm.search("net")
        #expect(vm.popularServices.allSatisfy { $0.name.lowercased().contains("net") })
    }

    @Test("selectPopular pre-fills input")
    func selectPopularPrefills() async {
        let (vm, _, _) = makeViewModel()
        let netflix = FakePopularServicesCatalog.defaultServices[0]
        vm.selectPopular(netflix)
        #expect(vm.input.serviceName == netflix.name)
        #expect(vm.input.brandColorHex == netflix.brandColorHex)
        #expect(vm.input.iconSymbolName == netflix.iconSymbolName)
        #expect(vm.input.category == netflix.category)
        #expect(vm.input.price == netflix.defaultPrice.amount)
        #expect(vm.input.currencyCode == netflix.defaultPrice.currencyCode)
        #expect(vm.input.billingCycle == netflix.defaultBillingCycle)
    }

    @Test("selectCustom resets input to defaults")
    func selectCustomResets() async {
        let (vm, _, _) = makeViewModel()
        vm.selectPopular(FakePopularServicesCatalog.defaultServices[0])
        vm.selectCustom()
        #expect(vm.input.serviceName.isEmpty)
        #expect(vm.input.price == 0)
        #expect(vm.input.brandColorHex == "#6C757D")
    }

    @Test("save fails on validation errors")
    func saveFailsOnValidation() async {
        let (vm, repo, _) = makeViewModel()
        let saved = await vm.save()
        #expect(saved == false)
        #expect(vm.validationErrors.contains(.emptyServiceName))
        #expect(vm.validationErrors.contains(.nonPositivePrice))
        #expect(repo.savedCallCount == 0)
    }

    @Test("save succeeds with valid input")
    func saveSucceeds() async {
        let (vm, repo, _) = makeViewModel()
        vm.selectPopular(FakePopularServicesCatalog.defaultServices[0])
        let saved = await vm.save()
        #expect(saved)
        #expect(vm.validationErrors.isEmpty)
        #expect(repo.savedCallCount == 1)
    }

    @Test("save with reminder schedules notification")
    func saveSchedulesReminder() async {
        let (vm, _, scheduling) = makeViewModel()
        vm.selectPopular(FakePopularServicesCatalog.defaultServices[0])
        vm.input.reminderOffset = 2
        let saved = await vm.save()
        #expect(saved)
        #expect(scheduling.scheduledLeadDays.values.contains(2))
    }

    @Test("cancel calls router.dismiss")
    func cancelDismisses() {
        let router = FakeSubscriptionsRouter()
        let (vm, _, _) = makeViewModel(router: router)
        vm.cancel()
        #expect(router.dismissCallCount == 1)
    }
}
