import XCTest
@testable import D2Utils

final class CircularArrayTests: XCTestCase {
	static var allTests = [
		("testCircularArray", testCircularArray)
	]
	
	func testCircularArray() throws {
		var a = CircularArray<String>(capacity: 5)
		XCTAssert(a.isEmpty, "\(a) should be empty after initialization")
		
		a.push("test")
		XCTAssertEqual(a.insertPos, 1)
		a.push("demo")
		XCTAssertEqual(a.insertPos, 2)
		XCTAssertEqual(Array(a), ["test", "demo"])
		
		a.push("1")
		XCTAssertEqual(a.insertPos, 3)
		a.push("2")
		XCTAssertEqual(a.insertPos, 4)
		a.push("3")
		XCTAssertEqual(a.insertPos, 0)
		a.push("4")
		XCTAssertEqual(a.insertPos, 1)
		XCTAssertEqual(Array(a), ["demo", "1", "2", "3", "4"])
		
		for _ in 0..<10 {
			a.push("...")
		}
		
		XCTAssertEqual(a.count, a.capacity)
	}
}
