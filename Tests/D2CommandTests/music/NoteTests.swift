import XCTest
@testable import D2Commands

final class NoteTests: XCTestCase {
	static var allTests = [
		("testNote", testNote)
	]
	
	func testNote() throws {
		guard let c4 = create(note: "C4") else { return }
		guard let d3 = create(note: "d3") else { return }
		guard let aSharp2 = create(note: "A#2") else { return }
		guard let fSharp = create(note: "F#") else { return }
		guard let gFlat1 = create(note: "Gb1") else { return }
		
		XCTAssertEqual(c4 + .majorSecond, create(note: "D4"))
		XCTAssertEqual(c4 - .minorSecond, create(note: "B3"))
		XCTAssertEqual(c4 - .majorSecond, create(note: "Bb3"))
		XCTAssertEqual(d3 + .minorThird, create(note: "F3"))
		XCTAssertEqual(d3 + .majorThird, create(note: "F#3"))
		XCTAssertEqual(aSharp2 + .unison, aSharp2)
		XCTAssertEqual(fSharp + .octave, fSharp)
		XCTAssertEqual(gFlat1 + .octave, create(note: "Gb2"))
	}
	
	private func create(note: String) -> Note? {
		if let note = Note(of: note) {
			return note
		} else {
			XCTFail("'\(note)' should be a note")
			return nil
		}
	}
}
