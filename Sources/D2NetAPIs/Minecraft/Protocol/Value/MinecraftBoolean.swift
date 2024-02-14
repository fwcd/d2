import Foundation

public struct MinecraftBoolean: MinecraftProtocolValue {
    public let value: Bool
    public var data: Data { return value ? Data([0x01]) : Data([0x00]) }

    public init(_ value: Bool) {
        self.value = value
    }

    public static func from(_ data: Data) -> (MinecraftBoolean, Int)? {
        guard let b = data.first else { return nil }
        return (.init(b == 0x00), 1)
    }
}
