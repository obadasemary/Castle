public enum Category: String, Hashable, Codable, Sendable, CaseIterable {
    case entertainment
    case ai
    case music
    case productivity
    case storage
    case other

    public var displayName: String {
        switch self {
        case .entertainment: "Entertainment"
        case .ai: "AI"
        case .music: "Music"
        case .productivity: "Productivity"
        case .storage: "Storage"
        case .other: "Other"
        }
    }

    public var iconSymbolName: String {
        switch self {
        case .entertainment: "play.tv"
        case .ai: "cpu"
        case .music: "music.note"
        case .productivity: "briefcase"
        case .storage: "externaldrive"
        case .other: "square.grid.2x2"
        }
    }
}
