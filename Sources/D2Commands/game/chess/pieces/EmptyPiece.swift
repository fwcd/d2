import D2Utils

public struct EmptyPiece: ChessPiece {
	public let notationLetters: [Character] = []
	
	public func possibleMoves(from position: Vec2<Int>, board: [[ChessPiece?]], role: ChessRole, firstMove: Bool) -> [Vec2<Int>] {
		return []
	}
}
