import Foundation
import Observation
import Core
import Domain

@Observable
@MainActor
public final class AddSubscriptionViewModel {
    public enum CatalogState: Sendable, Equatable {
        case idle
        case loading
        case loaded([PopularService])
        case error(String)
    }

    public var catalogState: CatalogState = .idle
    public var query: String = ""
    public var input: SubscriptionInput
    public var validationErrors: [ValidationError] = []
    public var saveErrorMessage: String?
    public var isSaving: Bool = false

    private let listPopular: ListPopularServicesUseCase
    private let validate: ValidateSubscriptionInputUseCase
    private let suggestNextDate: SuggestNextBillingDateUseCase
    private let addUseCase: AddSubscriptionUseCase
    private weak var router: (any SubscriptionsRouter)?

    public init(
        listPopular: ListPopularServicesUseCase,
        validate: ValidateSubscriptionInputUseCase,
        suggestNextDate: SuggestNextBillingDateUseCase,
        addUseCase: AddSubscriptionUseCase,
        router: (any SubscriptionsRouter)? = nil
    ) {
        self.listPopular = listPopular
        self.validate = validate
        self.suggestNextDate = suggestNextDate
        self.addUseCase = addUseCase
        self.router = router
        self.input = SubscriptionInput(nextBillingDate: suggestNextDate.execute(cycle: .monthly))
    }

    public var popularServices: [PopularService] {
        if case .loaded(let services) = catalogState { return services }
        return []
    }

    public func loadCatalog() async {
        catalogState = .loading
        do {
            let services = try await listPopular.execute(query: query)
            catalogState = .loaded(services)
        } catch {
            catalogState = .error(error.localizedDescription)
        }
    }

    public func search(_ newQuery: String) async {
        query = newQuery
        await loadCatalog()
    }

    public func selectPopular(_ service: PopularService) {
        input = SubscriptionInput(
            serviceName: service.name,
            price: service.defaultPrice.amount,
            currencyCode: service.defaultPrice.currencyCode,
            billingCycle: service.defaultBillingCycle,
            category: service.category,
            nextBillingDate: suggestNextDate.execute(cycle: service.defaultBillingCycle),
            iconSymbolName: service.iconSymbolName,
            brandColorHex: service.brandColorHex,
            reminderOffset: nil,
            notes: ""
        )
        validationErrors = []
        saveErrorMessage = nil
    }

    public func selectCustom() {
        input = SubscriptionInput(nextBillingDate: suggestNextDate.execute(cycle: .monthly))
        validationErrors = []
        saveErrorMessage = nil
    }

    @discardableResult
    public func save() async -> Bool {
        isSaving = true
        defer { isSaving = false }
        validationErrors = []
        saveErrorMessage = nil

        switch validate.execute(input) {
        case .failure(let errors):
            validationErrors = errors.values
            return false
        case .success(let validated):
            do {
                _ = try await addUseCase.execute(validated)
                return true
            } catch {
                saveErrorMessage = error.localizedDescription
                return false
            }
        }
    }

    public func cancel() {
        router?.dismiss()
    }
}
