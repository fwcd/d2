import Foundation

public struct MinecraftString: MinecraftProtocolValue {
    public let length: Int32
    public let value: String
    public var data: Data { return MinecraftVarInt(length).data + value.data(using: .utf8)! }
    
    public init(length: Int32, _ value: String) {
        self.length = length
        self.value = value
    }
    
    public static func from(_ data: Data) -> (MinecraftString, Int)? {
        guard let (length, lengthByteCount) = MinecraftVarInt.from(data) else { return nil }
        let content = data.advanced(by: lengthByteCount)
        guard let value = String(data: content, encoding: .utf8) else { return nil }
        return (MinecraftString(length: length.value, value), lengthByteCount + value.utf8.count)
    }
}
