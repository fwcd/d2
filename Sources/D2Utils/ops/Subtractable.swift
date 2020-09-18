public protocol Subtractable {
    static func -(lhs: Self, rhs: Self) -> Self

    static func -=(lhs: inout Self, rhs: Self)
}

extension Int: Subtractable {}
extension UInt: Subtractable {}
extension UInt32: Subtractable {}
extension UInt64: Subtractable {}
extension Double: Subtractable {}
