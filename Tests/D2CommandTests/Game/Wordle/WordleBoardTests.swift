import XCTest
@testable import D2Commands

final class WordleBoardTests: XCTestCase {
    func testClues() throws {
        XCTAssertEqual(WordleBoard.Clues(fromArray: [.here]).count, 1)
        XCTAssertEqual(WordleBoard.Clues(fromArray: [.nowhere, .somewhere]).count, 2)

        testCodingRoundtrip(for: [])
        testCodingRoundtrip(for: [.somewhere, .unknown])
        testCodingRoundtrip(for: [.nowhere, .somewhere, .somewhere, .here, .nowhere])
    }

    private func testCodingRoundtrip(for clues: [WordleBoard.Clue]) {
        XCTAssertEqual(Array(WordleBoard.Clues(fromArray: clues)), clues)
    }
}
