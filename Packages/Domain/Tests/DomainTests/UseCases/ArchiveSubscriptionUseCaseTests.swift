import Testing
import Foundation
import Core
@testable import Domain

@Suite("ArchiveSubscriptionUseCase")
struct ArchiveSubscriptionUseCaseTests {
    @Test("Archives active subscription")
    func archivesSubscription() async throws {
        let repo = FakeSubscriptionRepository()
        let sub = Subscription(
            serviceName: "Netflix",
            category: .entertainment,
            price: Money(amount: 15.99, currencyCode: "USD"),
            billingCycle: .monthly,
            nextBillingDate: Date().addingTimeInterval(86400),
            status: .active
        )
        try await repo.save(sub)

        let useCase = ArchiveSubscriptionUseCase(repository: repo)
        try await useCase.execute(id: sub.id)

        let updated = try await repo.fetch(id: sub.id)
        #expect(updated?.status == .archived)
    }

    @Test("Archive of non-existent ID does not throw")
    func nonExistentIDNoThrow() async throws {
        let repo = FakeSubscriptionRepository()
        let useCase = ArchiveSubscriptionUseCase(repository: repo)
        try await useCase.execute(id: UUID())
    }
}
