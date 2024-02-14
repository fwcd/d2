public protocol ToSourceServerPacket {
    var packet: SourceServerPacket { get }
}

extension SourceServerPacket: ToSourceServerPacket {
    public var packet: SourceServerPacket { return self }
}
