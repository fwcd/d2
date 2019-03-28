protocol Divisible {
	static func /(lhs: Self, rhs: Self) -> Self
}

extension Int: Divisible {}
extension Double: Divisible {}
