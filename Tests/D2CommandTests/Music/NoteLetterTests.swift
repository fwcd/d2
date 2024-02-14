import XCTest
import MusicTheory
@testable import D2Commands

final class NoteLetterTests: XCTestCase {
    func testNoteLetter() throws {
        XCTAssertEqual(NoteLetter(parsing: "C"), .c)
        XCTAssertEqual(NoteLetter(parsing: "d"), .d)
        XCTAssertEqual(NoteLetter(parsing: "a"), .a)
    }
}
