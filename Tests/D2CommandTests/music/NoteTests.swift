import XCTest
@testable import D2Commands

final class NoteTests: XCTestCase {
	func testNote() throws {
		let c4 = try Note(of: "C4")
		let d3 = try Note(of: "d3")
		let aSharp2 = try Note(of: "A#2")
		let fSharp = try Note(of: "F#")
		let fSharp7 = try Note(of: "F#7")
		let gFlat1 = try Note(of: "Gb1")

		XCTAssertEqual(c4 + .majorSecond, try Note(of: "D4"))
		XCTAssertEqual(c4 - .minorSecond, try Note(of: "B3"))
		XCTAssertEqual(c4 - .majorSecond, try Note(of: "Bb3"))
		XCTAssertEqual(c4 + .octaves(2), try Note(of: "C6"))
		XCTAssertEqual(c4 + .octaves(-1), try Note(of: "C3"))
		XCTAssertEqual(c4 - .octaves(3), try Note(of: "C1"))
		XCTAssertEqual(fSharp7 - .majorSeventh, try Note(of: "G6"))
		XCTAssertEqual(d3 + .minorThird, try Note(of: "F3"))
		XCTAssertEqual(d3 + .majorThird, try Note(of: "F#3"))
		XCTAssertEqual(aSharp2 + .unison, aSharp2)
		XCTAssertEqual(fSharp + .octave, fSharp)
		XCTAssertEqual(gFlat1 + .octave, try Note(of: "Gb2"))
	}
}
