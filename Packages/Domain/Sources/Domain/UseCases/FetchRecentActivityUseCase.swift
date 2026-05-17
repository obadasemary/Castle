public struct FetchRecentActivityUseCase: Sendable {
    private let paymentRepository: any PaymentRepository

    public init(paymentRepository: any PaymentRepository) {
        self.paymentRepository = paymentRepository
    }

    public func execute(limit: Int = 20) async throws -> [ActivityEvent] {
        let payments = try await paymentRepository.fetchRecent(limit: limit)
        return payments.map { payment in
            ActivityEvent(
                id: payment.id,
                subscriptionID: payment.subscriptionID,
                subscriptionName: payment.subscriptionName,
                type: .paid(amount: payment.amount),
                date: payment.date
            )
        }
    }
}
