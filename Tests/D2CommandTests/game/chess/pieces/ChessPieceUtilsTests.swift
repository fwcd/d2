import XCTest
import Utils
@testable import D2Commands

final class ChessPieceUtilsTests: XCTestCase {
	func testNeighborFields() throws {
		XCTAssertEqual(Set(neighborFields()), Set([
			Vec2(x: -1, y: -1),
			Vec2(x: 0, y: -1),
			Vec2(x: 1, y: -1),
			Vec2(x: -1, y: 0),
			Vec2(x: 1, y: 0),
			Vec2(x: -1, y: 1),
			Vec2(x: 0, y: 1),
			Vec2(x: 1, y: 1),
		]))
	}

	func testPieceLetters() throws {
		assert("Q", matchesPiece: .queen)
		assert("D", matchesPiece: .queen)
		assert("R", matchesPiece: .rook)
		assert("T", matchesPiece: .rook)
		assert("L", matchesPiece: .bishop)
		assert("B", matchesPiece: .bishop)
		assert("N", matchesPiece: .knight)
		assert("S", matchesPiece: .knight)
	}

	private func assert(_ letter: Character, matchesPiece pieceType: ChessPieceType) {
		XCTAssertEqual(pieceOf(letter: letter)?.pieceType, pieceType)
	}
}
