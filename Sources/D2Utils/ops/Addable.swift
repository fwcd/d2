public protocol Addable {
    static func +(lhs: Self, rhs: Self) -> Self

    static func +=(lhs: inout Self, rhs: Self)
}

extension Int: Addable {}
extension UInt: Addable {}
extension UInt32: Addable {}
extension UInt64: Addable {}
extension Double: Addable {}
