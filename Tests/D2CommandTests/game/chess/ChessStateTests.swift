import XCTest
@testable import D2Commands

final class ChessStateTests: XCTestCase {
	static var allTests = [
		("testPossibleMoves", testPossibleMoves)
	]
	
	func testPossibleMoves() throws {
		let state = ChessState(firstPlayer: GamePlayer(username: "Mr. White"), secondPlayer: GamePlayer(username: "Mr. Black"))
		let initialMoves = state.possibleMoves
		
		XCTAssert(initialMoves.allSatisfy { $0.color == .white }, "Initial moves should all be white")
		XCTAssert(initialMoves.allSatisfy { $0.isCapture == false }, "Initial moves should not contain captures (or unspecified 'isCapture' fields)")
		XCTAssert(initialMoves.contains(ChessMove(
			pieceType: .pawn,
			color: .white,
			originX: xOf(file: "e"),
			originY: yOf(rank: 2),
			isCapture: false,
			destinationX: xOf(file: "e"),
			destinationY: yOf(rank: 4),
			isEnPassant: false
		)), "Possible moves should contain pawn move e4-e6")
		assert(initialMoves, containsMove: "white knight b1 - c3")
		
		let secondState = try state.childState(after: move("white pawn e2 - e4", in: state.possibleMoves)!)
		let secondMoves = secondState.possibleMoves
		
		XCTAssert(secondMoves.allSatisfy { $0.color == .black }, "Second moves should all be black")
		assert(secondMoves, containsMove: "black pawn e7 - e6")
		assert(secondMoves, containsMove: "black pawn b7 - b5")
		assert(secondMoves, containsMove: "black knight g8 - f6")
	}
	
	private func assert(_ moves: Set<ChessMove>, containsMove moveDescription: String) {
		XCTAssert(moves.contains { $0.description == moveDescription }, "Moves should contain '\(moveDescription)'")
	}
	
	private func move(_ description: String, in moves: Set<ChessMove>) -> ChessMove? {
		return moves.first { $0.description == description }
	}
}
