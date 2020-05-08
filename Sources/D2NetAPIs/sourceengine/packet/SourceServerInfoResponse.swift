public struct SourceServerInfoResponse: FromSourceServerPacket {
    /// Protocol version
    public let protocolVersion: UInt8
    /// Server name
    public let name: String
    /// Currly loaded map
    public let map: String
    /// Name of the folder containing the game files
    public let folder: String
    /// Full name of the game
    public let game: String
    /// Steam application ID of the game
    public let id: UInt16
    /// Number of players on the server
    public let players: UInt8
    /// Maximum number of players on the server
    public let maxPlayers: UInt8
    /// Number of bots on the server
    public let bots: UInt8
    /// The server type
    public let serverType: ServerType
    /// The operating system
    public let environment: Environment
    /// Whether the server is public (i.e. does not require a password)
    public let isPublic: Bool
    /// Whether the server uses VAC
    public let usesVAC: Bool
    
    public init?(packet: SourceServerPacket) {
        var p = packet

        // Check header
        if p.readByte() == 0x49,
                let protocolVersion = p.readByte(),
                let name = p.readString(),
                let map = p.readString(),
                let folder = p.readString(),
                let game = p.readString(),
                let id = p.readShort(),
                let players = p.readByte(),
                let maxPlayers = p.readByte(),
                let bots = p.readByte(),
                let serverType = p.readByte().flatMap(ServerType.init(rawValue:)),
                let environment = p.readByte().flatMap(Environment.init(rawValue:)),
                let isPublic = p.readByte().map({ $0 == 0 }),
                let usesVAC = p.readByte().map({ $0 == 1 }) {
            self.protocolVersion = protocolVersion
            self.name = name
            self.map = map
            self.folder = folder
            self.game = game
            self.id = id
            self.players = players
            self.maxPlayers = maxPlayers
            self.bots = bots
            self.serverType = serverType
            self.environment = environment
            self.isPublic = isPublic
            self.usesVAC = usesVAC
        } else {
            return nil
        }
    }

    public enum ServerType: UInt8 {
        case dedicated = 0x64 // 'd'
        case nonDedicated = 0x6c // 'l'
        case proxy = 0x70 // 'p'
    }
    
    public enum Environment: UInt8 {
        case linux = 0x6c // 'l'
        case windows = 0x77 // 'w'
        case mac = 0x6d // 'm'
    }
}
