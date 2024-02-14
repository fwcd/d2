import Foundation

public protocol MinecraftProtocolValue {
    associatedtype Value
    var value: Value { get }
    var data: Data { get }

    /// Converts a serialized representation
    /// to a deserialized value and its
    /// serialized byte length.
    static func from(_ data: Data) -> (Self, Int)?
}
