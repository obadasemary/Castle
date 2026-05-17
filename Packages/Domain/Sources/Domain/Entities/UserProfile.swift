import Foundation
import Core

public struct UserProfile: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public var displayName: String
    public var preferredCurrencyCode: String
    public var monthlyBudget: Money?
    public var appearance: Appearance

    public enum Appearance: String, Hashable, Codable, Sendable, CaseIterable {
        case system, light, dark
    }

    public init(
        id: UUID = UUID(),
        displayName: String = "",
        preferredCurrencyCode: String = "USD",
        monthlyBudget: Money? = nil,
        appearance: Appearance = .system
    ) {
        self.id = id
        self.displayName = displayName
        self.preferredCurrencyCode = preferredCurrencyCode
        self.monthlyBudget = monthlyBudget
        self.appearance = appearance
    }
}
