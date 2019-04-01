import D2Utils

/** Encapsulates an unpositioned chess piece. */
public protocol ChessPiece {
	/**
	 * Contains possible notation letters. The preferred letter
	 * (which is used for encoding) should be at the first position,
	 * if present.
	 */
	var notationLetters: [Character] { get }
	
	/**
	 * Fetches the possible moves of this piece. The board variable
	 * contains all pieces *except* for the receiver.
	 *
	 * The implementor is responsible for checking that all moves are
	 * in the bounds of the board, however not for testing whether
	 * the given move would result in a check.
	 */
	func possibleMoves(from position: Vec2<Int>, board: [[ChessPiece?]]) -> [Vec2<Int>]
}
