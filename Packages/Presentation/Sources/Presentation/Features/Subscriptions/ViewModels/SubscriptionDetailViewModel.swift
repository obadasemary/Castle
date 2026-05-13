import Foundation
import Observation
import Domain

@Observable
@MainActor
public final class SubscriptionDetailViewModel {
    public enum State: Sendable {
        case idle
        case loading
        case loaded(FetchSubscriptionDetailUseCase.Detail)
        case notFound
        case error(String)
    }

    public var state: State = .idle

    private let subscriptionID: UUID
    private let fetchDetail: FetchSubscriptionDetailUseCase
    private let updateUseCase: UpdateSubscriptionUseCase
    private let archiveUseCase: ArchiveSubscriptionUseCase
    private let deleteUseCase: DeleteSubscriptionUseCase
    private weak var router: (any SubscriptionsRouter)?

    public init(
        subscriptionID: UUID,
        fetchDetail: FetchSubscriptionDetailUseCase,
        updateUseCase: UpdateSubscriptionUseCase,
        archiveUseCase: ArchiveSubscriptionUseCase,
        deleteUseCase: DeleteSubscriptionUseCase,
        router: (any SubscriptionsRouter)? = nil
    ) {
        self.subscriptionID = subscriptionID
        self.fetchDetail = fetchDetail
        self.updateUseCase = updateUseCase
        self.archiveUseCase = archiveUseCase
        self.deleteUseCase = deleteUseCase
        self.router = router
    }

    public var subscription: Subscription? {
        if case .loaded(let detail) = state { return detail.subscription }
        return nil
    }

    public var isReminderEnabled: Bool {
        (subscription?.reminderOffset ?? 0) > 0
    }

    public func load() async {
        state = .loading
        do {
            if let detail = try await fetchDetail.execute(id: subscriptionID) {
                state = .loaded(detail)
            } else {
                state = .notFound
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    public func toggleReminder(enabled: Bool, leadDays: Int = 1) async {
        guard var subscription else { return }
        subscription.reminderOffset = enabled ? max(1, leadDays) : nil
        do {
            try await updateUseCase.execute(subscription)
            await load()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    public func archive() async {
        do {
            try await archiveUseCase.execute(id: subscriptionID)
            router?.dismiss()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    public func delete() async {
        do {
            try await deleteUseCase.execute(id: subscriptionID)
            router?.dismiss()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
