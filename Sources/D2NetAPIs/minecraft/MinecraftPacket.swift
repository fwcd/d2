import Foundation

public struct MinecraftPacket {
    public private(set) var content: Data
    public var data: Data { return MinecraftVarInt(Int32(content.count)).data + content }
    
    public init?(data: Data) {
        guard let (length, byteCount) = MinecraftVarInt.from(data) else { return nil }
        content = data[byteCount..<(byteCount + Int(length.value))]
    }

    public init(packetId: Int32) {
        content = Data()
        write(MinecraftVarInt(packetId))
    }
    
    public mutating func write<V>(_ value: V) where V: MinecraftProtocolValue {
        content += value.data
    }
    
    public mutating func read<V>() -> V? where V: MinecraftProtocolValue {
        guard let (v, byteCount) = V.from(content) else { return nil }
        content = content.advanced(by: byteCount)
        return v
    }
}
