public protocol Multipliable {
	static func *(lhs: Self, rhs: Self) -> Self

	static func *=(lhs: inout Self, rhs: Self)
}

extension Int: Multipliable {}
extension Double: Multipliable {}
