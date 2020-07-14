public protocol Remainderable {
	static func %(lhs: Self, rhs: Self) -> Self

	static func %=(lhs: inout Self, rhs: Self)
}

extension Int: Remainderable {}
extension UInt: Remainderable {}
extension UInt32: Remainderable {}
extension UInt64: Remainderable {}
