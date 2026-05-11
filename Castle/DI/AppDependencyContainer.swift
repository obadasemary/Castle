// ── FILE: Castle/DI/AppDependencyContainer.swift ──
//
// Composition root. Owns the SwiftData ModelContainer, concrete repositories,
// use cases, and ViewModel factories. Inject only Domain protocols into
// Presentation — never concrete Data types.
//
// PR 1 stub: the real wiring lands in PR 2 (Domain protocols and use case
// defaults) and PR 3 (SwiftData ModelContainer + repository implementations).

import Foundation
import Core
import Domain
import Data
import Presentation

@MainActor
final class AppDependencyContainer {
    init() {
        // Real construction happens in PR 3 once SwiftDataModelContainerFactory
        // and the ModelActor repositories exist.
    }
}
