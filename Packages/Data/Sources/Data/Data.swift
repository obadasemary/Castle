// ── FILE: Packages/Data/Sources/Data/Data.swift ──
//
// Data module — concrete implementations of Domain repository protocols using
// SwiftData. Also owns the bundled popular-services catalog and the
// UNUserNotificationCenter scheduler. Never re-exports SwiftData @Model types
// past the protocol boundary.
//
// PR 1 placeholder. Real types land in PR 3.

import Foundation
import Core
import Domain

public enum DataModule {
    public static let identifier = "com.SamuraiStudios.Castle.Data"
}
