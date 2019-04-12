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
		a.push("demo")
		XCTAssertEqual(Array(a), ["test", "demo"])
		
		a.push("1")
		a.push("2")
		a.push("3")
		a.push("4")
		XCTAssertEqual(Array(a), ["4", "demo", "1", "2", "3"])
		
		for _ in 0..<10 {
			a.push("...")
		}
		
		XCTAssertEqual(a.count, a.capacity)
	}
}
