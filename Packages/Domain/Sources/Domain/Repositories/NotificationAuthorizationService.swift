public enum NotificationAuthorizationStatus: Hashable, Sendable {
    case notDetermined
    case denied
    case authorized
    case provisional
}

public protocol NotificationAuthorizationService: Sendable {
    func currentStatus() async -> NotificationAuthorizationStatus
    func requestAuthorization() async throws -> Bool
}
