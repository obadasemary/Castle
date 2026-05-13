import Foundation
import Core

final class FakeClock: Clock, @unchecked Sendable {
    var now: Date
    init(now: Date) { self.now = now }
}
