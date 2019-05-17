import XCTest
@testable import D2Utils

final class TokenIteratorTests: XCTestCase {
	static var allTests = [
		("testTokenIterator", testTokenIterator)
	]
	
	func testTokenIterator() throws {
		let fruits = ["Apple", "Orange", "Banana", "Pear", "Lemon", "Grapefruit"]
		let iterator = TokenIterator(fruits)
		
		XCTAssertEqual(iterator.peek(), "Apple")
		XCTAssertEqual(iterator.peek(2), "Orange")
		XCTAssertEqual(iterator.peek(1), "Apple")
		XCTAssertEqual(iterator.next(), "Apple")
		XCTAssertEqual(iterator.peek(), "Orange")
		XCTAssertEqual(iterator.next(), "Orange")
		XCTAssertEqual(iterator.next(), "Banana")
		XCTAssertEqual(iterator.next(), "Pear")
		XCTAssertEqual(iterator.peek(2), "Grapefruit")
		XCTAssertEqual(iterator.peek(), "Lemon")
		XCTAssertEqual(iterator.next(), "Lemon")
		XCTAssertEqual(iterator.next(), "Grapefruit")
		XCTAssertEqual(iterator.peek(), nil)
		XCTAssertEqual(iterator.next(), nil)
	}
}
