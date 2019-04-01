import D2Utils

public struct King: ChessPiece {
	public let notationLetters: [Character] = ["K"]
	
	// TODO: Castling
	
	public func possibleMoves(from position: Vec2<Int>, board: [[ChessPiece?]], role: ChessRole) -> [Vec2<Int>] {
		return neighbors(of: position)
			.map { $0 + position }
			.filter { board.isInBounds($0) }
	}
}
