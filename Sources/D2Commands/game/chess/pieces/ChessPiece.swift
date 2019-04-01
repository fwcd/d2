import D2Utils

/** Encapsulates an unpositioned chess piece. */
public protocol ChessPiece {
	/**
	 * Contains possible notation letters. The preferred letter
	 * (which is used for encoding) should be at the first position,
	 * if present.
	 */
	var notationLetters: [Character] { get }
	
	func reachablePositions(from position: Vec2<Int>, boardSize: Vec2<Int>) -> [Vec2<Int>]
}
