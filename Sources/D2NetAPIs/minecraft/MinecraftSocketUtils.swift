import Foundation
import Socket

extension Socket {
    func readMinecraftPacket() throws -> MinecraftPacket {
        var data = Data(capacity: 2048)

        var bytesRead = try read(into: &data)
        guard let (length, lenByteCount) = MinecraftVarInt.from(data) else { throw MinecraftPacketError.couldNotReadLength(data) }
        data = data.advanced(by: lenByteCount)
        bytesRead -= lenByteCount

        guard let (packetId, packetIdByteCount) = MinecraftVarInt.from(data) else { throw MinecraftPacketError.couldNotReadPacketId(data) }
        data = data.advanced(by: packetIdByteCount)

        while bytesRead < length.value {
            bytesRead += try read(into: &data)
        }

        return MinecraftPacket(id: packetId.value, content: data)
    }

    func write<P>(from packetable: P) throws where P: ToMinecraftPacket {
        try write(from: packetable.packet.data)
    }
}
