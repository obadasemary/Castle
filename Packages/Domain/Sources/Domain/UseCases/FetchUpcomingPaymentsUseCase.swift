import Core

public struct FetchUpcomingPaymentsUseCase: Sendable {
    private let repository: any SubscriptionRepository
    private let clock: any Clock
    private let calendarProvider: any CalendarProvider

    public init(
        repository: any SubscriptionRepository,
        clock: any Clock,
        calendarProvider: any CalendarProvider
    ) {
        self.repository = repository
        self.clock = clock
        self.calendarProvider = calendarProvider
    }

    public func execute(withinDays days: Int = 30) async throws -> [Subscription] {
        let all = try await repository.fetchAll()
        let now = clock.now
        let calendar = calendarProvider.calendar
        guard let cutoff = calendar.date(byAdding: .day, value: days, to: now) else { return [] }
        return all
            .filter { $0.status == .active && $0.nextBillingDate >= now && $0.nextBillingDate <= cutoff }
            .sorted { $0.nextBillingDate < $1.nextBillingDate }
    }
}
