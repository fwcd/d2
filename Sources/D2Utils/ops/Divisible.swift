public protocol Divisible {
	static func /(lhs: Self, rhs: Self) -> Self

	static func /=(lhs: inout Self, rhs: Self)
}

extension Int: Divisible {}
extension Double: Divisible {}
