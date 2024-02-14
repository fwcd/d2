import Foundation
import XCTest
@testable import D2NetAPIs

final class MinecraftVarIntTests: XCTestCase {
    func testVarInt() throws {
        XCTAssertEqual(encode(0), [0x00])
        XCTAssertEqual(encode(9987287), [0xD7, 0xC9, 0xE1, 0x04])
        XCTAssertEqual(decode([0xF9, 0x92, 0x05]), 84345)
    }

    func encode(_ i: Int32) -> [UInt8] {
        return [UInt8](MinecraftVarInt(i).data)
    }

    func decode(_ arr: [UInt8]) -> Int32 {
        let (v, _) = MinecraftVarInt.from(Data(arr))!
        return v.value
    }
}
