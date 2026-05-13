import Foundation
import SwiftUI

@MainActor
public protocol SubscriptionsViewModelFactory: AnyObject {
    func makeSubscriptionsListViewModel() -> SubscriptionsListViewModel
    func makeSubscriptionDetailViewModel(id: UUID) -> SubscriptionDetailViewModel
    func makeAddSubscriptionViewModel() -> AddSubscriptionViewModel
}

private struct SubscriptionsViewModelFactoryKey: EnvironmentKey {
    static let defaultValue: (any SubscriptionsViewModelFactory)? = nil
}

public extension EnvironmentValues {
    var subscriptionsViewModelFactory: (any SubscriptionsViewModelFactory)? {
        get { self[SubscriptionsViewModelFactoryKey.self] }
        set { self[SubscriptionsViewModelFactoryKey.self] = newValue }
    }
}
