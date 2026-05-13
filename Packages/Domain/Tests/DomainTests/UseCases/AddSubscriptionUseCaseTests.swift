import Testing
import Foundation
import Core
@testable import Domain

@Suite("AddSubscriptionUseCase")
struct AddSubscriptionUseCaseTests {
    private func makeInput() -> SubscriptionInput {
        SubscriptionInput(
            serviceName: "Netflix",
            price: 15.99,
            currencyCode: "USD",
            billingCycle: .monthly,
            category: .entertainment,
            nextBillingDate: Date().addingTimeInterval(86400 * 30)
        )
    }

    @Test("Saves subscription to repository and returns it")
    func savesSubscription() async throws {
        let repo = FakeSubscriptionRepository()
        let useCase = AddSubscriptionUseCase(repository: repo)
        let input = makeInput()

        let result = try await useCase.execute(input)

        #expect(result.serviceName == "Netflix")
        #expect(result.price.amount == 15.99)
        #expect(result.price.currencyCode == "USD")
        #expect(await repo.savedCallCount == 1)
        #expect(await repo.subscriptions[result.id] != nil)
    }

    @Test("Subscription starts with active status")
    func startsActive() async throws {
        let repo = FakeSubscriptionRepository()
        let useCase = AddSubscriptionUseCase(repository: repo)
        let result = try await useCase.execute(makeInput())
        #expect(result.status == .active)
    }
}
