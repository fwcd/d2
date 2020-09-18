public protocol Multipliable {
    static func *(lhs: Self, rhs: Self) -> Self

    static func *=(lhs: inout Self, rhs: Self)
}

extension Int: Multipliable {}
extension UInt: Multipliable {}
extension UInt32: Multipliable {}
extension UInt64: Multipliable {}
extension Double: Multipliable {}
