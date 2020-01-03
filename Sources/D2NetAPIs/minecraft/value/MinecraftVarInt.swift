import Foundation
import D2Utils

public struct MinecraftVarInt: MinecraftProtocolValue {
    public let value: Int32
    public var data: Data {
        // TODO
        return Data()
    }
    
    public init(_ value: Int32) {
        self.value = value
    }
    
    public static func from(_ data: Data) -> (MinecraftVarInt, Int)? {
        // TODO
        return (MinecraftVarInt(0), 0)
    }
}
