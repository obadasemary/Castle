// ── FILE: Packages/Core/Tests/CoreTests/CoreModuleTests.swift ──
import Testing
@testable import Core

@Suite("Core module")
struct CoreModuleTests {
    @Test("module identifier is namespaced under the app bundle")
    func identifierIsNamespaced() {
        #expect(CoreModule.identifier == "com.SamuraiStudios.Castle.Core")
    }
}
