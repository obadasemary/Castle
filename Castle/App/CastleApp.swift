// ── FILE: Castle/App/CastleApp.swift ──
//
// Composition entry point for the Castle subscription tracker.
// PR 1: imports Core/Domain/Data/Presentation to prove the SPM wiring is
// correct. The dependency container, navigation, and feature views land in
// subsequent PRs as described in /root/.claude/plans/cheerful-crunching-bengio.md.

import SwiftUI
import Core
import Domain
import Data
import Presentation

@main
struct CastleApp: App {
    @State private var environment = AppEnvironment.live()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
        }
    }
}
