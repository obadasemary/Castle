import Testing
import Foundation
import Core
@testable import Domain

@Suite("ValidateSubscriptionInputUseCase")
struct ValidateSubscriptionInputUseCaseTests {
    private let fixedNow = Date(timeIntervalSinceReferenceDate: 800_000_000)

    private var useCase: ValidateSubscriptionInputUseCase {
        ValidateSubscriptionInputUseCase(clock: FakeClock(now: fixedNow))
    }

    private func validInput() -> SubscriptionInput {
        SubscriptionInput(
            serviceName: "Netflix",
            price: 9.99,
            currencyCode: "USD",
            nextBillingDate: fixedNow.addingTimeInterval(86400)
        )
    }

    @Test("Valid input succeeds")
    func validInputSucceeds() {
        let result = useCase.execute(validInput())
        if case .failure(let errors) = result {
            Issue.record("Expected success but got errors: \(errors)")
        }
    }

    @Test("Empty service name produces error")
    func emptyServiceName() {
        var input = validInput()
        input.serviceName = "   "
        let result = useCase.execute(input)
        guard case .failure(let errors) = result else {
            Issue.record("Expected failure")
            return
        }
        #expect(errors.contains(.emptyServiceName))
    }

    @Test("Zero price produces error")
    func zeroPrice() {
        var input = validInput()
        input.price = 0
        let result = useCase.execute(input)
        guard case .failure(let errors) = result else {
            Issue.record("Expected failure")
            return
        }
        #expect(errors.contains(.nonPositivePrice))
    }

    @Test("Invalid currency code produces error")
    func invalidCurrencyCode() {
        var input = validInput()
        input.currencyCode = "US"
        let result = useCase.execute(input)
        guard case .failure(let errors) = result else {
            Issue.record("Expected failure")
            return
        }
        #expect(errors.contains(.invalidCurrencyCode))
    }

    @Test("Past billing date produces error")
    func pastBillingDate() {
        var input = validInput()
        input.nextBillingDate = fixedNow.addingTimeInterval(-86400)
        let result = useCase.execute(input)
        guard case .failure(let errors) = result else {
            Issue.record("Expected failure")
            return
        }
        #expect(errors.contains(.pastBillingDate))
    }

    @Test("Multiple errors returned together")
    func multipleErrors() {
        var input = validInput()
        input.serviceName = ""
        input.price = -1
        let result = useCase.execute(input)
        guard case .failure(let errors) = result else {
            Issue.record("Expected failure")
            return
        }
        #expect(errors.contains(.emptyServiceName))
        #expect(errors.contains(.nonPositivePrice))
    }
}
