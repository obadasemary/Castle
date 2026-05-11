import Testing
import Foundation
import SwiftData
@testable import Data

@Suite("ModelContainerFactory")
struct ModelContainerFactoryTests {
    @Test("inMemory factory returns a ready container")
    func inMemoryFactoryReturnsContainer() throws {
        let container = try ModelContainerFactory.inMemory()
        let context = ModelContext(container)
        #expect(try context.fetch(FetchDescriptor<SubscriptionModel>()).isEmpty)
    }

    @Test("inMemory factory returns isolated containers per call")
    func inMemoryFactoryReturnsIsolatedContainers() throws {
        let containerA = try ModelContainerFactory.inMemory()
        let containerB = try ModelContainerFactory.inMemory()

        let contextA = ModelContext(containerA)
        contextA.insert(SubscriptionModel(
            id: UUID(),
            serviceName: "A",
            categoryRaw: "other",
            priceAmount: 1,
            currencyCode: "USD",
            billingCycleRaw: "monthly",
            billingCycleCustomDays: nil,
            nextBillingDate: Date(),
            statusRaw: "active",
            reminderOffset: nil,
            brandColorHex: "#000000",
            iconSymbolName: "circle",
            notes: "",
            startDate: Date()
        ))
        try contextA.save()

        let contextB = ModelContext(containerB)
        #expect(try contextB.fetch(FetchDescriptor<SubscriptionModel>()).isEmpty)
    }
}
