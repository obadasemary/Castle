// ── FILE: Packages/Presentation/Sources/Presentation/Presentation.swift ──
//
// Presentation module — SwiftUI views, ViewModels (@Observable, @MainActor),
// per-feature router protocols, and the shared design system. Depends on
// Domain (for entities + use cases) and Core (for primitives). Never imports
// Data.
//
// PR 1 placeholder. Real types land in PR 4–8.

import Foundation
import Core
import Domain

public enum PresentationModule {
    public static let identifier = "com.SamuraiStudios.Castle.Presentation"
}
