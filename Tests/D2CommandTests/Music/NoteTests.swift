import Testing
import MusicTheory
@testable import D2Commands

struct NoteTests {
    @Test func note() throws {
        let c4 = try Note(parsing: "C4")
        let d3 = try Note(parsing: "d3")
        let aSharp2 = try Note(parsing: "A#2")
        let fSharp7 = try Note(parsing: "F#7")
        let gFlat1 = try Note(parsing: "Gb1")

        #expect(try c4 + .majorSecond == Note(parsing: "D4"))
        #expect(try c4 - .minorSecond == Note(parsing: "B3"))
        #expect(try c4 - .majorSecond == Note(parsing: "Bb3"))
        #expect(try c4 + .octaves(2) == Note(parsing: "C6"))
        #expect(try c4 + .octaves(-1) == Note(parsing: "C3"))
        #expect(try c4 - .octaves(3) == Note(parsing: "C1"))
        #expect(try fSharp7 - .majorSeventh == Note(parsing: "G6"))
        #expect(try d3 + .minorThird == Note(parsing: "F3"))
        #expect(try d3 + .majorThird == Note(parsing: "F#3"))
        #expect(aSharp2 + .unison == aSharp2)
        #expect(try gFlat1 + .octave == Note(parsing: "Gb2"))
    }
}
