import Foundation
import D2Utils

public struct MinecraftVarInt: MinecraftProtocolValue {
    // Encoding and decoding algorithms adapted from https://wiki.vg/Protocol#VarInt_and_VarLong

    public let value: Int32
    public var data: Data {
        var d = Data()
        var v = UInt32(bitPattern: value)

        repeat {
            var tmp = UInt8(v & 0b01111111)
            v >>= 7
            if v != 0 {
                tmp |= 0b10000000
            }
            d.append(tmp)
        } while v != 0

        return d
    }
    
    public init(_ value: Int32) {
        self.value = value
    }
    
    public static func from(_ data: Data) -> (MinecraftVarInt, Int)? {
        var d = data
        var byteCount = 0
        var value: Int32 = 0
        var tmp: UInt8 = 0
        
        repeat {
            print(byteCount)
            guard byteCount < data.count else { return nil }
            guard let b = d.popFirst() else { return nil }
            tmp = b
            let v = tmp & 0b01111111
            value |= Int32(v) << (7 * byteCount)

            byteCount += 1
            guard byteCount <= 5 else { return nil }
        } while (tmp & 0b10000000) != 0
        
        print("Done decoding varint")
        return (MinecraftVarInt(value), byteCount)
    }
}
