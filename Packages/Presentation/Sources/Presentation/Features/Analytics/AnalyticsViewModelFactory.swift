import Foundation
import SwiftUI

@MainActor
public protocol AnalyticsViewModelFactory: AnyObject, Sendable {
    func makeAnalyticsViewModel() -> AnalyticsViewModel
}

private struct AnalyticsViewModelFactoryKey: EnvironmentKey {
    static let defaultValue: (any AnalyticsViewModelFactory)? = nil
}

public extension EnvironmentValues {
    var analyticsViewModelFactory: (any AnalyticsViewModelFactory)? {
        get { self[AnalyticsViewModelFactoryKey.self] }
        set { self[AnalyticsViewModelFactoryKey.self] = newValue }
    }
}
