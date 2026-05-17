// ── FILE: Packages/Presentation/Tests/PresentationTests/PresentationModuleTests.swift ──
import Testing
@testable import Presentation

@Suite("Presentation module")
struct PresentationModuleTests {
    @Test("module identifier is namespaced under the app bundle")
    func identifierIsNamespaced() {
        #expect(PresentationModule.identifier == "com.SamuraiStudios.Castle.Presentation")
    }
}
