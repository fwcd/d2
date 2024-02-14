public protocol MessageIOConvertible {
    associatedtype MessageIOType

    var usingMessageIO: MessageIOType { get }
}

extension Dictionary: MessageIOConvertible where Key: MessageIOConvertible, Value: MessageIOConvertible, Key.MessageIOType: Hashable {
    public var usingMessageIO: [Key.MessageIOType: Value.MessageIOType] {
        [Key.MessageIOType: Value.MessageIOType](uniqueKeysWithValues: map { ($0.usingMessageIO, $1.usingMessageIO) })
    }
}

extension Array: MessageIOConvertible where Element: MessageIOConvertible {
    public var usingMessageIO: [Element.MessageIOType] {
        map { $0.usingMessageIO }
    }
}

extension Optional: MessageIOConvertible where Wrapped: MessageIOConvertible {
    public var usingMessageIO: Wrapped.MessageIOType? {
        map(\.usingMessageIO)
    }
}
