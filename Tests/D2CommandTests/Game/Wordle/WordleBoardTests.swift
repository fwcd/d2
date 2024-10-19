import Testing
@testable import D2Commands

struct WordleBoardTests {
    @Test func clues() {
        #expect(WordleBoard.Clues(fromArray: [.here]).count == 1)
        #expect(WordleBoard.Clues(fromArray: [.nowhere, .somewhere]).count == 2)
    }

    @Test(arguments: [
        [WordleBoard.Clue](),
        [.somewhere, .unknown],
        [.nowhere, .somewhere, .somewhere, .here, .nowhere],
    ]) func codingRoundtrip(clues: [WordleBoard.Clue]) {
        #expect(Array(WordleBoard.Clues(fromArray: clues)) == clues)
    }
}
