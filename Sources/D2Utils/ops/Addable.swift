public protocol Addable {
	static func +(lhs: Self, rhs: Self) -> Self

	static func +=(lhs: inout Self, rhs: Self)
}

extension Int: Addable {}
extension Double: Addable {}
