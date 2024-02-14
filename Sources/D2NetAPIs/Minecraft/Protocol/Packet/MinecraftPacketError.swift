import Foundation

public enum MinecraftPacketError: Error {
    case couldNotReadLength(Data)
    case couldNotReadPacketId(Data)
    case couldNotDecode(Data)
    case couldNotEncode(String)
    case malformedPacket(MinecraftPacket)
}
