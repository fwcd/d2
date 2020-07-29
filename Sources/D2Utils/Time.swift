import Foundation

/**
 * Represents a time, independent of the date.
 * Often viewed as an hour-minute-second tuple.
 */
public struct Time {
    public let hour: Int
    public let minute: Int
    public let second: Int

    public var secondOfDay: Int {
        return second + (minute * 60) + (hour * 3600)
    }
    public var minuteOfDay: Int {
        return minute + (hour * 60)
    }

    public init?(hour: Int, minute: Int, second: Int = 0) {
        if hour >= 0 && hour < 24 && minute >= 0 && minute < 60 && second >= 0 && second < 60 {
            self.hour = hour
            self.minute = minute
            self.second = second
        } else {
            return nil
        }
    }

    public func timeInterval(to other: Time) -> TimeInterval {
        return TimeInterval(other.secondOfDay - secondOfDay)
    }

    public func seconds(to other: Time) -> Int {
        return other.secondOfDay - secondOfDay
    }

    public func minutes(to other: Time) -> Int {
        return other.minuteOfDay - minuteOfDay
    }

    public func hours(to other: Time) -> Int {
        return other.hour - hour
    }
}
