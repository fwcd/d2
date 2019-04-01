import D2Utils

public struct Queen: ChessPiece {
	public let pieceType: ChessPieceType = .queen
	public let notationLetters: [Character] = ["Q"]
	
	public func possibleMoves(from position: Vec2<Int>, board: [[ColoredPieceType?]], role: ChessRole, firstMove: Bool) -> [Vec2<Int>] {
		return neighbors(of: position)
			.flatMap { moves(into: $0, from: position, board: board) }
	}
}
