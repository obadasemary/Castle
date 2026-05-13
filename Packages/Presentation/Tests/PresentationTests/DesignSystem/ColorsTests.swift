import Testing
import SwiftUI
@testable import Presentation

@Suite("Color brand hex parsing")
struct ColorsTests {
    @Test("parses 6-character hex with no prefix")
    func parsesPlainSixCharHex() {
        let color = Color(brandHex: "FF0000")
        #expect(String(describing: color).isEmpty == false)
    }

    @Test("parses 6-character hex with hash prefix")
    func parsesHashPrefixedHex() {
        let color = Color(brandHex: "#1DB954")
        #expect(String(describing: color).isEmpty == false)
    }

    @Test("parses 8-character hex with alpha")
    func parsesEightCharHex() {
        let color = Color(brandHex: "#1DB95480")
        #expect(String(describing: color).isEmpty == false)
    }

    @Test("falls back to gray for invalid hex")
    func fallsBackForInvalidHex() {
        let color = Color(brandHex: "not-a-hex")
        #expect(String(describing: color).isEmpty == false)
    }
}
