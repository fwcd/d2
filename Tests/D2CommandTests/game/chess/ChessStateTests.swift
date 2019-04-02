import XCTest
@testable import D2Commands

final class ChessStateTests: XCTestCase {
	static var allTests = [
		("testPossibleMoves", testPossibleMoves)
	]
	
	func testPossibleMoves() throws {
		let state = ChessState(firstPlayer: GamePlayer(username: "Mr. White"), secondPlayer: GamePlayer(username: "Mr. Black"))
		let moves = state.possibleMoves
		
		XCTAssert(moves.allSatisfy { $0.color == .white }, "Initial moves should all be white")
		XCTAssert(moves.allSatisfy { $0.isCapture == false }, "Initial moves should not contain captures (or unspecified 'isCapture' fields)")
		XCTAssert(moves.contains(ChessMove(
			pieceType: .pawn,
			color: .white,
			originX: xOf(file: "e"),
			originY: yOf(rank: 4),
			isCapture: false,
			destinationX: xOf(file: "e"),
			destinationY: yOf(rank: 6),
			isEnPassant: false
		)), "Possible moves should contain pawn move e4-e6")
	}
}
