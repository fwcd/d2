protocol Remainderable {
	static func %(lhs: Self, rhs: Self) -> Self
}

extension Int: Remainderable {}
