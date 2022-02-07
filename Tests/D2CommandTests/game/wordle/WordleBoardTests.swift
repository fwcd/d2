import XCTest
@testable import D2Commands

final class WordleBoardTests: XCTestCase {
    func testClues() throws {
        XCTAssertEqual(WordleBoard.Clues(fromArray: [.unknown, .unknown]).rawValue, 0)
        XCTAssertEqual(WordleBoard.Clues(fromArray: [.nowhere, .somewhere]).rawValue, 0b1001)

        testCodingRoundtrip(for: [])
        testCodingRoundtrip(for: [.somewhere, .unknown])
        testCodingRoundtrip(for: [.nowhere, .somewhere, .somewhere, .here, .nowhere])
    }

    private func testCodingRoundtrip(for clues: [WordleBoard.Clue]) {
        XCTAssertEqual(WordleBoard.Clues(fromArray: clues).asArray(count: clues.count), clues)
    }
}
