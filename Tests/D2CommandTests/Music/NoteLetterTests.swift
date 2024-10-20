import Testing
import MusicTheory
@testable import D2Commands

struct NoteLetterTests {
    @Test func noteLetter() {
        #expect(NoteLetter(parsing: "C") == .c)
        #expect(NoteLetter(parsing: "d") == .d)
        #expect(NoteLetter(parsing: "a") == .a)
    }
}
