import Foundation

public struct MinecraftPacket {
    public let id: Int32
    public private(set) var content: Data
    public var data: Data {
        return MinecraftVarInt(Int32(content.count)).data + MinecraftVarInt(id).data + content
    }
    
    public init?(data: Data) {
        guard let (length, lenByteCount) = MinecraftVarInt.from(data) else { return nil }
        let restData = data[lenByteCount..<(lenByteCount + Int(length.value))]
        guard let (id, idByteCount) = MinecraftVarInt.from(restData) else { return nil }
        self.id = id.value
        content = restData[idByteCount...]
    }

    public init(id: Int32) {
        self.id = id
        content = Data()
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
