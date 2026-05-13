import Foundation
import Observation
import SwiftUI
import Domain
#if canImport(UIKit)
import UIKit
#endif

public enum AppTab: String, CaseIterable, Hashable, Sendable {
    case dashboard, subscriptions, analytics, settings

    public var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .subscriptions: "Subscriptions"
        case .analytics: "Analytics"
        case .settings: "Settings"
        }
    }

    public var symbolName: String {
        switch self {
        case .dashboard: "square.grid.2x2.fill"
        case .subscriptions: "creditcard.fill"
        case .analytics: "chart.pie.fill"
        case .settings: "gearshape.fill"
        }
    }
}

public enum SubscriptionsRoute: Hashable, Sendable {
    case detail(UUID)
}

public enum DashboardRoute: Hashable, Sendable {
    case subscriptionDetail(UUID)
}

public enum AnalyticsRoute: Hashable, Sendable {
    case category(Category)
}

@Observable
@MainActor
public final class AppCoordinator {
    public var selectedTab: AppTab = .dashboard
    public var subscriptionsPath = NavigationPath()
    public var dashboardPath = NavigationPath()
    public var analyticsPath = NavigationPath()
    public var settingsPath = NavigationPath()
    public var isPresentingAddSubscription: Bool = false

    public init() {}
}

extension AppCoordinator: DashboardRouter {
    public func showSubscriptions() {
        selectedTab = .subscriptions
    }

    public func showSubscriptionDetail(_ id: UUID) {
        selectedTab = .subscriptions
        subscriptionsPath.append(SubscriptionsRoute.detail(id))
    }

    public func showAnalytics() {
        selectedTab = .analytics
    }
}

extension AppCoordinator: SubscriptionsRouter {
    public func presentAdd() {
        isPresentingAddSubscription = true
    }

    public func showDetail(_ id: UUID) {
        subscriptionsPath.append(SubscriptionsRoute.detail(id))
    }

    public func dismiss() {
        if !subscriptionsPath.isEmpty {
            subscriptionsPath.removeLast()
        } else {
            isPresentingAddSubscription = false
        }
    }
}

extension AppCoordinator: AnalyticsRouter {
    public func showCategoryDetail(_ category: Category) {
        analyticsPath.append(AnalyticsRoute.category(category))
    }
}

extension AppCoordinator: SettingsRouter {
    public func openSystemSettings() {
        #if canImport(UIKit) && !os(watchOS) && !os(tvOS)
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            Task { @MainActor in
                await UIApplication.shared.open(url)
            }
        }
        #endif
    }
}
