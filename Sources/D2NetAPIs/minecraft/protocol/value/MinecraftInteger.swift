import Foundation

public struct MinecraftInteger<I: FixedWidthInteger>: MinecraftProtocolValue {
    public let value: I
    public var data: Data { withUnsafeBytes(of: value.bigEndian) { Data($0) } }

    public init(_ value: I) {
        self.value = value
    }

    public static func from(_ data: Data) -> (MinecraftInteger<I>, Int)? {
        let number = data.withUnsafeBytes { $0.load(as: I.self) }
        return (MinecraftInteger(I.init(bigEndian: number)), I.bitWidth)
    }
}
