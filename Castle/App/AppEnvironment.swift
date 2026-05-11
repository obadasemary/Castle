// ── FILE: Castle/App/AppEnvironment.swift ──
//
// Process-wide runtime configuration: build flavour, locale, currency, and
// the resolved dependency container. The container itself stays empty in
// PR 1 and is populated as later PRs land Domain use cases, SwiftData
// repositories, and Presentation factories.

import Foundation
import Observation

@Observable
@MainActor
final class AppEnvironment {
    enum BuildFlavour: String {
        case debug, release
    }

    let buildFlavour: BuildFlavour
    let bundleIdentifier: String

    init(buildFlavour: BuildFlavour, bundleIdentifier: String) {
        self.buildFlavour = buildFlavour
        self.bundleIdentifier = bundleIdentifier
    }

    static func live() -> AppEnvironment {
        #if DEBUG
        let flavour: BuildFlavour = .debug
        #else
        let flavour: BuildFlavour = .release
        #endif
        return AppEnvironment(
            buildFlavour: flavour,
            bundleIdentifier: Bundle.main.bundleIdentifier ?? "com.SamuraiStudios.Castle"
        )
    }
}
