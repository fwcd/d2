public struct SourceServerPlayerResponse: FromSourceServerPacket {
    public let players: [Player]

    public init?(packet: SourceServerPacket) {
        var p = packet

        // Check header
        if p.readByte() == 0x44, let playerCount = p.readByte() {
            var players = [Player]()

            for _ in 0..<playerCount {
                guard let index = p.readByte(),
                    let name = p.readString(),
                    let score = p.readLong(),
                    let duration = p.readFloat() else { return nil }
                players.append(Player(
                    index: index,
                    name: name,
                    score: score,
                    duration: duration
                ))
            }

            self.players = players
        } else {
            return nil
        }
    }

    public struct Player {
        public let index: UInt8
        public let name: String
        public let score: UInt32
        public let duration: Float32
    }
}
