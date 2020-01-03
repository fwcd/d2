import Foundation

public enum MinecraftPacketError: Error {
    case couldNotDecode(Data)
    case couldNotEncode(String)
    case malformedPacket(MinecraftPacket)
}
