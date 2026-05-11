import Foundation
import Core

enum BillingCycleStorage {
    static let monthly = "monthly"
    static let annual = "annual"
    static let custom = "custom"

    static func encode(_ cycle: BillingCycle) -> (raw: String, customDays: Int?) {
        switch cycle {
        case .monthly: (monthly, nil)
        case .annual: (annual, nil)
        case .custom(let days): (custom, days)
        }
    }

    static func decode(raw: String, customDays: Int?) -> BillingCycle {
        switch raw {
        case annual: .annual
        case custom: .custom(days: customDays ?? 30)
        default: .monthly
        }
    }
}
