import Foundation
import XCTest
@testable import D2NetAPIs

final class MinecraftIntegerTests: XCTestCase {
    static var allTests = [
        ("testInteger", testInteger)
    ]
    
    func testInteger() throws {
        XCTAssertEqual(encode(0), [0x00, 0x00])
        XCTAssertEqual(encode(3234), [0x0C, 0xA2])
    }
    
    func encode(_ i: Int16) -> [UInt8] {
        return [UInt8](MinecraftInteger(i).data)
    }
}
