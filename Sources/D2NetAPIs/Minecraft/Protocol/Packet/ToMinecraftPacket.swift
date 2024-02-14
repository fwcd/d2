public protocol ToMinecraftPacket {
    var packet: MinecraftPacket { get }
}

extension MinecraftPacket: ToMinecraftPacket {
    public var packet: MinecraftPacket { return self }
}
