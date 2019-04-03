/** Describes a (signed) type that has an additive inverse. */
public protocol Negatable {
	prefix static func -(operand: Self) -> Self
}

extension Int: Negatable {}
extension Double: Negatable {}
