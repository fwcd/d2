import XCTest
@testable import D2Commands

final class NoteTests: XCTestCase {
	static var allTests = [
		("testNote", testNote)
	]
	
	func testNote() throws {
		let c4 = try Note(of: "C4")
		let d3 = try Note(of: "d3")
		let aSharp2 = try Note(of: "A#2")
		let fSharp = try Note(of: "F#")
		let gFlat1 = try Note(of: "Gb1")
		
		XCTAssertEqual(c4 + .majorSecond, try Note(of: "D4"))
		XCTAssertEqual(c4 - .minorSecond, try Note(of: "B3"))
		XCTAssertEqual(c4 - .majorSecond, try Note(of: "Bb3"))
		XCTAssertEqual(d3 + .minorThird, try Note(of: "F3"))
		XCTAssertEqual(d3 + .majorThird, try Note(of: "F#3"))
		XCTAssertEqual(aSharp2 + .unison, aSharp2)
		XCTAssertEqual(fSharp + .octave, fSharp)
		XCTAssertEqual(gFlat1 + .octave, try Note(of: "Gb2"))
	}
}
