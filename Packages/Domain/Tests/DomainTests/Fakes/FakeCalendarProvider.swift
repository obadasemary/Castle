import Foundation
import Core

struct FakeCalendarProvider: CalendarProvider {
    let calendar: Calendar

    init(timeZoneIdentifier: String = "UTC") {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? .gmt
        self.calendar = cal
    }
}
