import Foundation
import Core

struct FakeClock: Clock {
    let now: Date
    init(now: Date) { self.now = now }
}
