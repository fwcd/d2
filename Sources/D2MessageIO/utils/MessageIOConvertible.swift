public protocol MessageIOConvertible {
    associatedtype MessageIOType

    var usingMessageIO: MessageIOType { get }
}

extension Dictionary: MessageIOConvertible where Key: MessageIOConvertible, Value: MessageIOConvertible, Key.MessageIOType: Hashable {
    public var usingMessageIO: [Key.MessageIOType: Value.MessageIOType] {
        return [Key.MessageIOType: Value.MessageIOType](uniqueKeysWithValues: map { ($0.usingMessageIO, $1.usingMessageIO) })
    }
}

extension Array: MessageIOConvertible where Element: MessageIOConvertible {
    public var usingMessageIO: [Element.MessageIOType] {
        return map { $0.usingMessageIO }
    }
}
