import Foundation
import SwiftUI

@MainActor
public protocol DashboardViewModelFactory: AnyObject, Sendable {
    func makeDashboardViewModel() -> DashboardViewModel
}

private struct DashboardViewModelFactoryKey: EnvironmentKey {
    static let defaultValue: (any DashboardViewModelFactory)? = nil
}

public extension EnvironmentValues {
    var dashboardViewModelFactory: (any DashboardViewModelFactory)? {
        get { self[DashboardViewModelFactoryKey.self] }
        set { self[DashboardViewModelFactoryKey.self] = newValue }
    }
}
