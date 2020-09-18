public struct MinecraftHandshake: ToMinecraftPacket {
    public let protocolVersion: Int32
    public let serverAddress: String
    public let serverPort: UInt16
    public let nextState: NextState

    public var packet: MinecraftPacket {
        var p = MinecraftPacket(id: 0x00)

        p.write(MinecraftVarInt(protocolVersion))
        p.write(MinecraftString(serverAddress))
        p.write(MinecraftInteger<UInt16>(serverPort))
        p.write(MinecraftVarInt(nextState.rawValue))

        return p
    }

    public enum NextState: Int32 {
        case status = 1
        case login = 2
    }

    public init(
        protocolVersion: Int32 = 0,
        serverAddress: String = "localhost",
        serverPort: UInt16 = 25565,
        nextState: NextState = .status
    ) {
        self.protocolVersion = protocolVersion
        self.serverAddress = serverAddress
        self.serverPort = serverPort
        self.nextState = nextState
    }
}
