import Testing
import Foundation
@testable import Core

@Suite("BillingCycleCalculator")
struct BillingCycleCalculatorTests {
    private func utcCalendar() -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }

    private func date(year: Int, month: Int, day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = 12
        return utcCalendar().date(from: comps)!
    }

    @Test("Monthly advances by one month")
    func monthlyAdvance() {
        let result = BillingCycleCalculator.nextDate(after: date(year: 2025, month: 3, day: 15), cycle: .monthly, calendar: utcCalendar())
        #expect(utcCalendar().dateComponents([.year, .month, .day], from: result) == DateComponents(year: 2025, month: 4, day: 15))
    }

    @Test("Jan 31 monthly rolls to Feb 28 in non-leap year")
    func jan31ToFeb28() {
        let result = BillingCycleCalculator.nextDate(after: date(year: 2025, month: 1, day: 31), cycle: .monthly, calendar: utcCalendar())
        let comps = utcCalendar().dateComponents([.month, .day], from: result)
        #expect(comps.month == 2)
        #expect(comps.day == 28)
    }

    @Test("Jan 31 monthly rolls to Feb 29 in leap year")
    func jan31ToFeb29LeapYear() {
        let result = BillingCycleCalculator.nextDate(after: date(year: 2024, month: 1, day: 31), cycle: .monthly, calendar: utcCalendar())
        let comps = utcCalendar().dateComponents([.month, .day], from: result)
        #expect(comps.month == 2)
        #expect(comps.day == 29)
    }

    @Test("Mar 31 monthly rolls to Apr 30")
    func mar31ToApr30() {
        let result = BillingCycleCalculator.nextDate(after: date(year: 2025, month: 3, day: 31), cycle: .monthly, calendar: utcCalendar())
        let comps = utcCalendar().dateComponents([.month, .day], from: result)
        #expect(comps.month == 4)
        #expect(comps.day == 30)
    }

    @Test("Annual advances by one year")
    func annualAdvance() {
        let result = BillingCycleCalculator.nextDate(after: date(year: 2024, month: 6, day: 15), cycle: .annual, calendar: utcCalendar())
        let comps = utcCalendar().dateComponents([.year, .month, .day], from: result)
        #expect(comps.year == 2025)
        #expect(comps.month == 6)
        #expect(comps.day == 15)
    }

    @Test("Feb 29 annual in leap year rolls to Feb 28 in non-leap year")
    func feb29AnnualToFeb28() {
        let result = BillingCycleCalculator.nextDate(after: date(year: 2024, month: 2, day: 29), cycle: .annual, calendar: utcCalendar())
        let comps = utcCalendar().dateComponents([.month, .day], from: result)
        #expect(comps.month == 2)
        #expect(comps.day == 28)
    }

    @Test("Custom 14 days advances by 14 days")
    func custom14Days() {
        let result = BillingCycleCalculator.nextDate(after: date(year: 2025, month: 1, day: 20), cycle: .custom(days: 14), calendar: utcCalendar())
        let comps = utcCalendar().dateComponents([.month, .day], from: result)
        #expect(comps.month == 2)
        #expect(comps.day == 3)
    }

    @Test("Monthly cycle returns price unchanged")
    func monthlyEquivalentMonthly() {
        let price = Money(amount: 9.99, currencyCode: "USD")
        let result = BillingCycleCalculator.monthlyEquivalent(price: price, cycle: .monthly)
        #expect(result.amount == 9.99)
    }

    @Test("Annual cycle divides by 12")
    func monthlyEquivalentAnnual() {
        let price = Money(amount: 120, currencyCode: "USD")
        let result = BillingCycleCalculator.monthlyEquivalent(price: price, cycle: .annual)
        #expect(result.amount == 10)
    }

    @Test("Custom 30-day cycle equals monthly")
    func monthlyEquivalentCustom30() {
        let price = Money(amount: 9.99, currencyCode: "USD")
        let result = BillingCycleCalculator.monthlyEquivalent(price: price, cycle: .custom(days: 30))
        #expect(result.amount == 9.99)
    }

    @Test("daysUntil returns 0 for past date")
    func daysUntilPast() {
        let clock = FakeClock(now: date(year: 2025, month: 5, day: 10))
        let pastDate = date(year: 2025, month: 5, day: 1)
        #expect(BillingCycleCalculator.daysUntil(pastDate, clock: clock, calendar: utcCalendar()) == 0)
    }

    @Test("daysUntil counts correctly for future date")
    func daysUntilFuture() {
        let clock = FakeClock(now: date(year: 2025, month: 5, day: 1))
        let future = date(year: 2025, month: 5, day: 11)
        #expect(BillingCycleCalculator.daysUntil(future, clock: clock, calendar: utcCalendar()) == 10)
    }
}
