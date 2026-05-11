// ── FILE: Packages/Data/Tests/DataTests/DataModuleTests.swift ──
import Testing
@testable import Data

@Suite("Data module")
struct DataModuleTests {
    @Test("module identifier is namespaced under the app bundle")
    func identifierIsNamespaced() {
        #expect(DataModule.identifier == "com.SamuraiStudios.Castle.Data")
    }
}
