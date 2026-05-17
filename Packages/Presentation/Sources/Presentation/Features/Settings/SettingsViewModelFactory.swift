import Foundation
import SwiftUI

@MainActor
public protocol SettingsViewModelFactory: AnyObject, Sendable {
    func makeSettingsViewModel() -> SettingsViewModel
}

private struct SettingsViewModelFactoryKey: EnvironmentKey {
    static let defaultValue: (any SettingsViewModelFactory)? = nil
}

public extension EnvironmentValues {
    var settingsViewModelFactory: (any SettingsViewModelFactory)? {
        get { self[SettingsViewModelFactoryKey.self] }
        set { self[SettingsViewModelFactoryKey.self] = newValue }
    }
}
