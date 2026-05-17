import SwiftUI
import Domain

enum CategoryColor {
    static func color(for category: Domain.Category) -> Color {
        switch category {
        case .entertainment: Color(red: 0.85, green: 0.27, blue: 0.55)
        case .ai: Color(red: 0.35, green: 0.30, blue: 0.95)
        case .music: Color(red: 0.13, green: 0.70, blue: 0.41)
        case .productivity: Color(red: 0.95, green: 0.62, blue: 0.10)
        case .storage: Color(red: 0.25, green: 0.55, blue: 0.90)
        case .other: Color(red: 0.55, green: 0.55, blue: 0.58)
        }
    }
}
