import XCTest
@testable import D2Commands

final class NoteLetterTests: XCTestCase {
	static var allTests = [
		("testNoteLetter", testNoteLetter)
	]
	
	func testNoteLetter() throws {
		let c = NoteLetter.c
		
		XCTAssertEqual(c.next, .d)
		XCTAssertEqual(c.previous, .b)
		XCTAssertEqual(NoteLetter.a + 3, .d)
		XCTAssertEqual(NoteLetter.e - 5, .g)
		XCTAssertEqual(NoteLetter.f + 7, .f)
		XCTAssertEqual(NoteLetter.a + 15, .b)
		
		XCTAssertEqual(NoteLetter.of("C"), .c)
		XCTAssertEqual(NoteLetter.of("d"), .d)
		XCTAssertEqual(NoteLetter.of("H"), .b)
		XCTAssertEqual(NoteLetter.of("a"), .a)
	}
}
