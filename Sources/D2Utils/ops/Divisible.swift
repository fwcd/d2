public protocol Divisible {
    static func /(lhs: Self, rhs: Self) -> Self

    static func /=(lhs: inout Self, rhs: Self)
}

extension Int: Divisible {}
extension UInt: Divisible {}
extension UInt32: Divisible {}
extension UInt64: Divisible {}
extension Double: Divisible {}
