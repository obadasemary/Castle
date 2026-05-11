public enum BillingCycle: Hashable, Codable, Sendable {
    case monthly
    case annual
    case custom(days: Int)
}
