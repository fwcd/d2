import XCTest
@testable import D2Utils

final class BitDataTests: XCTestCase {
    static var allTests = [
        ("testBitData", testBitData)
    ]
    
    func testBitData() throws {
        var sink1 = BitData()
        XCTAssertEqual([UInt8](sink1.data), [0])
        sink1.write(0b11, bitCount: 2)
        XCTAssertEqual([UInt8](sink1.data), [0b11])
        sink1.write(0b0, bitCount: 1)
        XCTAssertEqual([UInt8](sink1.data), [0b011])
        sink1.write(0b0101, bitCount: 4)
        XCTAssertEqual([UInt8](sink1.data), [0b0101011])
        sink1.write(0b101, bitCount: 3)
        XCTAssertEqual([UInt8](sink1.data), [0b10101011, 0b10])
        
        var source1 = BitData(from: sink1.data)
        XCTAssertEqual(source1.read(bitCount: 2), 0b11)
        XCTAssertEqual(source1.read(bitCount: 1), 0b0)
        XCTAssertEqual(source1.read(bitCount: 4), 0b0101)
        XCTAssertEqual(source1.read(bitCount: 3), 0b101)
        
        var sink2 = BitData()
        sink2.write(0xABCD, bitCount: 16)

        var source2 = BitData(from: sink2.data)
        XCTAssertEqual(source2.read(bitCount: 16), 0xABCD)
    }
}
