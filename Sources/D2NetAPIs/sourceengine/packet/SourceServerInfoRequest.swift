public struct SourceServerInfoRequest: ToSourceServerPacket {
    public var packet: SourceServerPacket {
        var p = SourceServerPacket(header: 0x54)
        p.write(string: "Source Engine Query")
        return p
    }
    
    public init() {}
}
