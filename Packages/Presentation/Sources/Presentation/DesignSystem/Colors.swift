import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public extension Color {
    static var castleSurface: Color {
        #if canImport(UIKit)
        Color(uiColor: .systemBackground)
        #else
        Color(red: 1.0, green: 1.0, blue: 1.0)
        #endif
    }

    static var castleSurfaceElevated: Color {
        #if canImport(UIKit)
        Color(uiColor: .secondarySystemBackground)
        #else
        Color(red: 0.95, green: 0.95, blue: 0.97)
        #endif
    }

    static var castleSurfaceMuted: Color {
        #if canImport(UIKit)
        Color(uiColor: .tertiarySystemBackground)
        #else
        Color(red: 0.92, green: 0.92, blue: 0.94)
        #endif
    }

    static var castleAccentBrand: Color {
        Color(red: 0.35, green: 0.30, blue: 0.95)
    }

    static var castleAccentBrandMuted: Color {
        castleAccentBrand.opacity(0.12)
    }

    static var castleStatusActive: Color {
        Color(red: 0.13, green: 0.70, blue: 0.41)
    }

    static var castleStatusExpiring: Color {
        Color(red: 0.95, green: 0.62, blue: 0.10)
    }

    static var castleStatusArchived: Color {
        Color(red: 0.55, green: 0.55, blue: 0.58)
    }

    static var castleTextPrimary: Color { .primary }
    static var castleTextSecondary: Color { .secondary }

    static var castleDivider: Color {
        #if canImport(UIKit)
        Color(uiColor: .separator)
        #else
        Color.gray.opacity(0.3)
        #endif
    }

    init(brandHex hex: String) {
        let trimmed = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleaned = trimmed.hasPrefix("#") ? String(trimmed.dropFirst()) : trimmed
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let r, g, b, a: Double
        switch cleaned.count {
        case 8:
            r = Double((value >> 24) & 0xFF) / 255.0
            g = Double((value >> 16) & 0xFF) / 255.0
            b = Double((value >> 8) & 0xFF) / 255.0
            a = Double(value & 0xFF) / 255.0
        case 6:
            r = Double((value >> 16) & 0xFF) / 255.0
            g = Double((value >> 8) & 0xFF) / 255.0
            b = Double(value & 0xFF) / 255.0
            a = 1.0
        default:
            r = 0.5
            g = 0.5
            b = 0.5
            a = 1.0
        }

        self = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
