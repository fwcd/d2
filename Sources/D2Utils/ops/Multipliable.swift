public protocol Multipliable {
	static func *(lhs: Self, rhs: Self) -> Self
}

extension Int: Multipliable {}
extension Double: Multipliable {}
