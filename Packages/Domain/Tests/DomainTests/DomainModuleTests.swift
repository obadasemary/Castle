// ── FILE: Packages/Domain/Tests/DomainTests/DomainModuleTests.swift ──
import Testing
@testable import Domain

@Suite("Domain module")
struct DomainModuleTests {
    @Test("module identifier is namespaced under the app bundle")
    func identifierIsNamespaced() {
        #expect(DomainModule.identifier == "com.SamuraiStudios.Castle.Domain")
    }
}
