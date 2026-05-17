import Foundation

public enum BillingCycleCalculator {
    /// Advances `date` by exactly one billing cycle.
    ///
    /// Calendar.date(byAdding:) already clamps end-of-month: Jan 31 + 1 month → Feb 28/29.
    public static func nextDate(after date: Date, cycle: BillingCycle, calendar: Calendar) -> Date {
        switch cycle {
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .annual:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        case .custom(let days):
            return calendar.date(byAdding: .day, value: days, to: date) ?? date
        }
    }

    /// Returns the monthly-equivalent price for budget comparison.
    /// Custom cycles normalise to a 30-day month.
    public static func monthlyEquivalent(price: Money, cycle: BillingCycle) -> Money {
        switch cycle {
        case .monthly:
            return price
        case .annual:
            return Money(amount: price.amount / 12, currencyCode: price.currencyCode)
        case .custom(let days):
            guard days > 0 else { return price }
            let monthlyAmount = price.amount * Decimal(30) / Decimal(days)
            return Money(amount: monthlyAmount, currencyCode: price.currencyCode)
        }
    }

    /// Days from `clock.now` until `date`. Returns 0 if `date` is today or in the past.
    public static func daysUntil(_ date: Date, clock: any Clock, calendar: Calendar) -> Int {
        let now = clock.now
        guard date > now else { return 0 }
        return calendar.dateComponents([.day], from: now, to: date).day ?? 0
    }
}
