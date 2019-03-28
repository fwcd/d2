public protocol Addable {
	static func +(lhs: Self, rhs: Self) -> Self
}

extension Int: Addable {}
extension Double: Addable {}
