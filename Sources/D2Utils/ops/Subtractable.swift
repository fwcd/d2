public protocol Subtractable {
	static func -(lhs: Self, rhs: Self) -> Self

	static func -=(lhs: inout Self, rhs: Self)
}

extension Int: Subtractable {}
extension Double: Subtractable {}
