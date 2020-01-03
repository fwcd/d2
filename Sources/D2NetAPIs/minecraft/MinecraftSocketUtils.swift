import Foundation
import Socket

extension Socket {
    func readMinecraftPacket() throws -> MinecraftPacket {
        var data = Data(capacity: 2048)
        let _ = try read(into: &data)
        guard let packet = MinecraftPacket(data: data) else { throw MinecraftPacketError.couldNotDecode(data) }
        return packet
    }
    
    func write<P>(from packetable: P) throws where P: ToMinecraftPacket {
        try write(from: packetable.packet.data)
    }
}
