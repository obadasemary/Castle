import Domain

actor FakeNotificationAuthorizationService: NotificationAuthorizationService {
    var status: NotificationAuthorizationStatus
    var requestCallCount = 0
    var grantOnRequest: Bool

    init(status: NotificationAuthorizationStatus = .notDetermined, grantOnRequest: Bool = true) {
        self.status = status
        self.grantOnRequest = grantOnRequest
    }

    func setStatus(_ value: NotificationAuthorizationStatus) {
        status = value
    }

    func currentStatus() async -> NotificationAuthorizationStatus { status }

    func requestAuthorization() async throws -> Bool {
        requestCallCount += 1
        status = grantOnRequest ? .authorized : .denied
        return grantOnRequest
    }
}
