public struct SourceServerChallengeResponse: FromSourceServerPacket {
    public let challenge: UInt32
    
    public init?(packet: SourceServerPacket) {
        var p = packet
        
        // Check header
        if p.readByte() == 0x41, let challenge = p.readLong() {
            self.challenge = challenge
        } else {
            return nil
        }
    }
}
