/** Describes a (signed) type that has an additive inverse. */
public protocol Negatable {
    mutating func negate()

    prefix static func -(operand: Self) -> Self
}

extension Int: Negatable {}
extension Double: Negatable {}
