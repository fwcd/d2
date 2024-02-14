public struct SourceServerPlayerRequest: ToSourceServerPacket {
    private var challenge: UInt32
    public var packet: SourceServerPacket {
        var p = SourceServerPacket(header: 0x55)
        p.write(long: challenge)
        return p
    }

    public init(challenge: UInt32 = 0xFFFFFFFF) {
        self.challenge = challenge
    }
}
