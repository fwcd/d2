import Foundation
import Testing
@testable import D2NetAPIs

struct MinecraftIntegerTests {
    @Test func integer() {
        #expect(encode(0) == [0x00, 0x00])
        #expect(encode(3234) == [0x0C, 0xA2])
    }

    func encode(_ i: Int16) -> [UInt8] {
        return [UInt8](MinecraftInteger(i).data)
    }
}
