import XCTest
import D2Utils
@testable import D2Graphics

final class LzwEncoderTests: XCTestCase {
	static var allTests = [
		("testLzwEncoder", testLzwEncoder)
	]
	// Using the sample image from
	// http://giflib.sourceforge.net/whatsinagif/lzw_image_data.html
	private let indices = [
		1, 1, 1, 1, 1, 2, 2, 2, 2, 2,
		1, 1, 1, 1, 1, 2, 2, 2, 2, 2,
		1, 1, 1, 1, 1, 2, 2, 2, 2, 2,
		1, 1, 1, 0, 0, 0, 0, 2, 2, 2,
		1, 1, 1, 0, 0, 0, 0, 2, 2, 2,
		2, 2, 2, 0, 0, 0, 0, 1, 1, 1,
		2, 2, 2, 0, 0, 0, 0, 1, 1, 1,
		2, 2, 2, 2, 2, 1, 1, 1, 1, 1,
		2, 2, 2, 2, 2, 1, 1, 1, 1, 1,
		2, 2, 2, 2, 2, 1, 1, 1, 1, 1
	]
	
	func testLzwEncoder() throws {
		var i = 0
		var encoder = LzwEncoder(colorCount: 4)
		var encoded = BitData()
		
		encoder.beginEncoding(in: &encoded)
		
		// Each code uses 3 bits in the output
		XCTAssertEqual(encoder.table.meta.codeSize, 3)
		XCTAssertEqual(encoder.table.count, 6)
		
		// See http://giflib.sourceforge.net/whatsinagif/lzw_image_data.html#lzw_bytes
		// for details on this example
		encodeNext(with: &encoder, into: &encoded, &i)
		XCTAssertEqual(encoder.table.count, 6)
		XCTAssertEqual([UInt8](encoded.data), [0b00000100]) // #4
		
		encodeNext(with: &encoder, into: &encoded, &i)
		XCTAssertEqual(encoder.table.count, 7)
		XCTAssertEqual([UInt8](encoded.data), [0b00001100]) // #4 #1
		
		encodeNext(with: &encoder, into: &encoded, &i)
		XCTAssertEqual(encoder.table.count, 7)
		XCTAssertEqual([UInt8](encoded.data), [0b00001100]) // #4 #1
		
		encodeNext(with: &encoder, into: &encoded, &i)
		XCTAssertEqual(encoder.table.count, 8)
		XCTAssertEqual([UInt8](encoded.data), [0b10001100, 0b00000001]) // #4 #1 #6
		
		encodeNext(with: &encoder, into: &encoded, &i)
		XCTAssertEqual(encoder.table.count, 8)
		XCTAssertEqual([UInt8](encoded.data), [0b10001100, 0b00000001]) // #4 #1 #6
		
		encodeNext(with: &encoder, into: &encoded, &i)
		XCTAssertEqual(encoder.table.count, 9)
		XCTAssertEqual(encoder.table.meta.codeSize, 4)
		XCTAssertEqual([UInt8](encoded.data), [0b10001100, 0b00001101]) // #4 #1 #6 #6
		
		encodeNext(with: &encoder, into: &encoded, &i)
		XCTAssertEqual(encoder.table.count, 10)
		XCTAssertEqual([UInt8](encoded.data), [0b10001100, 0b00101101, 0b00000000]) // #4 #1 #6 #6 #2
		
		encodeNext(with: &encoder, into: &encoded, &i)
		XCTAssertEqual(encoder.table.count, 10)
		XCTAssertEqual([UInt8](encoded.data), [0b10001100, 0b00101101, 0b00000000]) // #4 #1 #6 #6 #2
	}
	
	private func encodeNext(with encoder: inout LzwEncoder, into data: inout BitData, _ i: inout Int) {
		encoder.encodeAndAppend(index: indices[i], into: &data)
		i += 1
	}
}
