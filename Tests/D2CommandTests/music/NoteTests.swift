import XCTest
import MusicTheory
@testable import D2Commands

final class NoteTests: XCTestCase {
	func testNote() throws {
		let c4 = try Note(parsing: "C4")
		let d3 = try Note(parsing: "d3")
		let aSharp2 = try Note(parsing: "A#2")
		let fSharp = try Note(parsing: "F#")
		let fSharp7 = try Note(parsing: "F#7")
		let gFlat1 = try Note(parsing: "Gb1")

		XCTAssertEqual(c4 + .majorSecond, try Note(parsing: "D4"))
		XCTAssertEqual(c4 - .minorSecond, try Note(parsing: "B3"))
		XCTAssertEqual(c4 - .majorSecond, try Note(parsing: "Bb3"))
		XCTAssertEqual(c4 + .octaves(2), try Note(parsing: "C6"))
		XCTAssertEqual(c4 + .octaves(-1), try Note(parsing: "C3"))
		XCTAssertEqual(c4 - .octaves(3), try Note(parsing: "C1"))
		XCTAssertEqual(fSharp7 - .majorSeventh, try Note(parsing: "G6"))
		XCTAssertEqual(d3 + .minorThird, try Note(parsing: "F3"))
		XCTAssertEqual(d3 + .majorThird, try Note(parsing: "F#3"))
		XCTAssertEqual(aSharp2 + .unison, aSharp2)
		XCTAssertEqual(fSharp + .octave, fSharp)
		XCTAssertEqual(gFlat1 + .octave, try Note(parsing: "Gb2"))
	}
}
