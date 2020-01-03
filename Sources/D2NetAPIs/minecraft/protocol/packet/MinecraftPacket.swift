import Foundation

public struct MinecraftPacket {
    public let id: Int32
    public private(set) var content: Data
    public var data: Data {
        let idData = MinecraftVarInt(id).data
        let lenData = MinecraftVarInt(Int32(content.count + idData.count)).data
        return lenData + idData + content
    }
    
    public init?(data: Data) {
        guard let (length, lenByteCount) = MinecraftVarInt.from(data) else { return nil }
        let restData = data.advanced(by: lenByteCount)
        guard let (id, idByteCount) = MinecraftVarInt.from(restData) else { return nil }
        self.id = id.value
        content = restData.advanced(by: idByteCount)
    }

    public init(id: Int32) {
        self.id = id
        content = Data()
    }
    
    public mutating func write<V>(_ value: V) where V: MinecraftProtocolValue {
        content += value.data
    }
    
    public mutating func read<V>(advance: Bool = true) -> V? where V: MinecraftProtocolValue {
        guard let (v, byteCount) = V.from(content) else { return nil }
        if byteCount < content.count {
            content = content.advanced(by: byteCount)
        } else {
            content = Data()
        }
        return v
    }
}
