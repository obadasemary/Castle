import Core
import Foundation

public struct SuggestNextBillingDateUseCase: Sendable {
    private let clock: any Clock
    private let calendarProvider: any CalendarProvider

    public init(clock: any Clock, calendarProvider: any CalendarProvider) {
        self.clock = clock
        self.calendarProvider = calendarProvider
    }

    public func execute(cycle: BillingCycle) -> Date {
        BillingCycleCalculator.nextDate(
            after: clock.now,
            cycle: cycle,
            calendar: calendarProvider.calendar
        )
    }
}
