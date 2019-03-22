import Foundation

/**
 * Represents a time, independent of the date.
 * Often viewed as an hour-minute-second tuple.
 */
struct Time {
	let hour: Int
	let minute: Int
	let second: Int
	
	var secondOfDay: Int {
		return second + (minute * 60) + (hour * 3600)
	}
	var minuteOfDay: Int {
		return minute + (hour * 60)
	}
	
	init?(hour: Int, minute: Int, second: Int = 0) {
		if hour >= 0 && hour < 24 && minute >= 0 && minute < 60 && second >= 0 && second < 60 {
			self.hour = hour
			self.minute = minute
			self.second = second
		} else {
			return nil
		}
	}
	
	func timeInterval(to other: Time) -> TimeInterval {
		return TimeInterval(other.secondOfDay - secondOfDay)
	}
	
	func seconds(to other: Time) -> Int {
		return other.secondOfDay - secondOfDay
	}
	
	func minutes(to other: Time) -> Int {
		return other.minuteOfDay - minuteOfDay
	}
	
	func hours(to other: Time) -> Int {
		return other.hour - hour
	}
}
