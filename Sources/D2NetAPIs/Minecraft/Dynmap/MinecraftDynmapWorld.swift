public struct MinecraftDynmapWorld: Sendable, Codable {
    public let currentcount: Int?
    public let hasStorm: Bool?
    public let players: [Player]?
    public let isThundering: Bool?
    public let confighash: Int?
    public let servertime: Int?
    public let timestamp: Int?

    public struct Player: Sendable, Codable {
        public let world: String?
        public let armor: Int?
        public let health: Double?
        public let name: String?
        public let x: Double?
        public let y: Double?
        public let z: Double?
        public let sort: Int?
        public let type: String?
        public let account: String?
    }
}
