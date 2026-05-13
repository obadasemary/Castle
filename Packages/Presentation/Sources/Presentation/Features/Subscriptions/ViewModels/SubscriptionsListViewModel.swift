import Foundation
import Observation
import Domain

@Observable
@MainActor
public final class SubscriptionsListViewModel {
    public enum Filter: String, CaseIterable, Hashable, Sendable {
        case active
        case archived

        public var title: String {
            switch self {
            case .active: "Active"
            case .archived: "Archived"
            }
        }
    }

    public enum State: Sendable, Equatable {
        case idle
        case loading
        case loaded([Subscription])
        case error(String)
    }

    public var state: State = .idle
    public var filter: Filter = .active

    private let repository: any SubscriptionRepository
    private let fetchActive: FetchActiveSubscriptionsUseCase
    private let archiveUseCase: ArchiveSubscriptionUseCase
    private let deleteUseCase: DeleteSubscriptionUseCase
    private weak var router: (any SubscriptionsRouter)?

    public init(
        repository: any SubscriptionRepository,
        fetchActive: FetchActiveSubscriptionsUseCase,
        archiveUseCase: ArchiveSubscriptionUseCase,
        deleteUseCase: DeleteSubscriptionUseCase,
        router: (any SubscriptionsRouter)? = nil
    ) {
        self.repository = repository
        self.fetchActive = fetchActive
        self.archiveUseCase = archiveUseCase
        self.deleteUseCase = deleteUseCase
        self.router = router
    }

    public func load() async {
        state = .loading
        do {
            let subs: [Subscription]
            switch filter {
            case .active:
                subs = try await fetchActive.execute()
            case .archived:
                let all = try await repository.fetchAll()
                subs = all
                    .filter { $0.status == .archived }
                    .sorted { $0.nextBillingDate > $1.nextBillingDate }
            }
            state = .loaded(subs)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    public func setFilter(_ newFilter: Filter) async {
        guard newFilter != filter else { return }
        filter = newFilter
        await load()
    }

    public func archive(id: UUID) async {
        do {
            try await archiveUseCase.execute(id: id)
            await load()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    public func delete(id: UUID) async {
        do {
            try await deleteUseCase.execute(id: id)
            await load()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    public func presentAdd() {
        router?.presentAdd()
    }

    public func showDetail(_ id: UUID) {
        router?.showDetail(id)
    }
}
