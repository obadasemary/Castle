import Core

public struct MonthlySpend: Hashable, Sendable {
    public let year: Int
    public let month: Int  // 1–12
    public let total: Money

    public init(year: Int, month: Int, total: Money) {
        self.year = year
        self.month = month
        self.total = total
    }
}

public struct BuildSpendingTrendUseCase: Sendable {
    private let paymentRepository: any PaymentRepository
    private let clock: any Clock
    private let calendarProvider: any CalendarProvider

    public init(
        paymentRepository: any PaymentRepository,
        clock: any Clock,
        calendarProvider: any CalendarProvider
    ) {
        self.paymentRepository = paymentRepository
        self.clock = clock
        self.calendarProvider = calendarProvider
    }

    public func execute(currencyCode: String, months: Int = 6) async throws -> [MonthlySpend] {
        let now = clock.now
        let calendar = calendarProvider.calendar
        var results: [MonthlySpend] = []

        for i in 0..<months {
            let offset = -(months - 1 - i)
            guard let targetDate = calendar.date(byAdding: .month, value: offset, to: now) else { continue }
            let components = calendar.dateComponents([.year, .month], from: targetDate)
            guard let year = components.year, let month = components.month else { continue }

            var startComps = DateComponents()
            startComps.year = year
            startComps.month = month
            startComps.day = 1
            guard
                let startOfMonth = calendar.date(from: startComps),
                let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: startOfMonth)
            else { continue }

            let payments = try await paymentRepository.fetchPayments(
                from: startOfMonth,
                to: endOfMonth,
                currencyCode: currencyCode
            )
            let total = payments.reduce(Decimal.zero) { $0 + $1.amount.amount }
            results.append(MonthlySpend(year: year, month: month, total: Money(amount: total, currencyCode: currencyCode)))
        }
        return results
    }
}
