import Foundation
import Domain

@MainActor
public protocol DashboardRouter: AnyObject {
    func showSubscriptions()
    func showSubscriptionDetail(_ id: UUID)
    func showAnalytics()
}

@MainActor
public protocol SubscriptionsRouter: AnyObject {
    func presentAdd()
    func showDetail(_ id: UUID)
    func dismiss()
}

@MainActor
public protocol AnalyticsRouter: AnyObject {
    func showCategoryDetail(_ category: Domain.Category)
}

@MainActor
public protocol SettingsRouter: AnyObject {
    func openSystemSettings()
}
