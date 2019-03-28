public protocol Subtractable {
	static func -(lhs: Self, rhs: Self) -> Self
}

extension Int: Subtractable {}
extension Double: Subtractable {}
