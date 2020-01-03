import Foundation
import Socket

public struct MinecraftServerPing {
    private let host: String
    private let port: Int32
    private let timeoutMs: UInt

    public init(host: String, port: Int32 = 25565, timeoutMs: UInt = 0) {
        self.host = host
        self.port = port
        self.timeoutMs = timeoutMs
    }
    
    public func perform() throws -> MinecraftServerInfo {
        let socket = try Socket.create()
        try socket.connect(to: host, port: port, timeout: timeoutMs)

        try socket.write(from: MinecraftHandshake(serverAddress: host, serverPort: UInt16(port), nextState: .status))
        try socket.write(from: MinecraftPacket(id: 0x00))
        
        var packet = try socket.readMinecraftPacket()
        guard let response: MinecraftString = packet.read() else { throw MinecraftPacketError.malformedPacket(packet) }
        guard let json = response.value.data(using: .utf8) else { throw MinecraftPacketError.couldNotEncode(response.value) }
        return try JSONDecoder().decode(MinecraftServerInfo.self, from: json)
    }
}
