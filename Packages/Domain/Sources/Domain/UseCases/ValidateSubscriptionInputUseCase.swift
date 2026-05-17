import Core

public enum ValidationError: Error, Sendable, Equatable {
    case emptyServiceName
    case nonPositivePrice
    case invalidCurrencyCode  // must be exactly 3 uppercase letters
    case pastBillingDate
}

public struct ValidationErrors: Error, Sendable, Equatable {
    public let values: [ValidationError]

    public init(_ values: [ValidationError]) {
        self.values = values
    }

    public func contains(_ error: ValidationError) -> Bool {
        values.contains(error)
    }
}

public struct ValidateSubscriptionInputUseCase: Sendable {
    private let clock: any Clock

    public init(clock: any Clock) {
        self.clock = clock
    }

    public func execute(_ input: SubscriptionInput) -> Result<SubscriptionInput, ValidationErrors> {
        var errors: [ValidationError] = []
        if input.serviceName.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(.emptyServiceName)
        }
        if input.price <= 0 {
            errors.append(.nonPositivePrice)
        }
        let code = input.currencyCode
        if code.count != 3 || !code.allSatisfy({ $0.isLetter && $0.isUppercase }) {
            errors.append(.invalidCurrencyCode)
        }
        if input.nextBillingDate < clock.now {
            errors.append(.pastBillingDate)
        }
        return errors.isEmpty ? .success(input) : .failure(ValidationErrors(errors))
    }
}
