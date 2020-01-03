import Foundation

public struct MinecraftString: MinecraftProtocolValue {
    public let value: String
    public var data: Data {
        let data = value.data(using: .utf8)!
        return MinecraftVarInt(Int32(data.count)).data + data
    }
    
    public init(_ value: String) {
        self.value = value
    }
    
    public static func from(_ data: Data) -> (MinecraftString, Int)? {
        guard let (_, lengthByteCount) = MinecraftVarInt.from(data) else { return nil }
        let content = data.advanced(by: lengthByteCount)
        guard let value = String(data: content, encoding: .utf8) else { return nil }
        return (MinecraftString(value), lengthByteCount + value.utf8.count)
    }
}
