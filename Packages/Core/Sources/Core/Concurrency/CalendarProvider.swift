import Foundation

public protocol CalendarProvider: Sendable {
    var calendar: Calendar { get }
}

public struct SystemCalendarProvider: CalendarProvider {
    public init() {}
    public var calendar: Calendar { .current }
}
