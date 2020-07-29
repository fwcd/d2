public protocol UnsignedConvertible {
    associatedtype Unsigned: FixedWidthInteger

    var bitPatternUnsigned: Unsigned { get }

    init(bitPattern: Unsigned)
}

extension Int32: UnsignedConvertible {
    public var bitPatternUnsigned: UInt32 { return UInt32(bitPattern: self) }
}

extension Int64: UnsignedConvertible {
    public var bitPatternUnsigned: UInt64 { return UInt64(bitPattern: self) }
}
