import XCTest
@testable import D2Utils

final class BitArrayTests: XCTestCase {
	static var allTests = [
		("testBitArray", testBitArray)
	]
	
	func testBitArray() throws {
		var arr = BitArray()
		XCTAssertEqual(arr.bytes, [])
		
		arr.append(bit: 1)
		arr.append(bit: 0)
		arr.append(bool: true)
		XCTAssertEqual(arr.bytes, [0b10100000])
		
		for _ in 0..<8 {
			arr.append(bit: 0)
		}
		arr.append(bit: 1)
		XCTAssertEqual(arr.bytes, [0b10100000, 0b00010000])
	}
}
