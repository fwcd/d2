import Foundation
import Testing
@testable import D2NetAPIs

struct MinecraftVarIntTests {
    @Test func varInt() throws {
        #expect(encode(0) == [0x00])
        #expect(encode(9987287) == [0xD7, 0xC9, 0xE1, 0x04])
        #expect(decode([0xF9, 0x92, 0x05]) == 84345)
    }

    func encode(_ i: Int32) -> [UInt8] {
        return [UInt8](MinecraftVarInt(i).data)
    }

    func decode(_ arr: [UInt8]) -> Int32 {
        let (v, _) = MinecraftVarInt.from(Data(arr))!
        return v.value
    }
}
