import D2Utils

public struct Knight: ChessPiece {
	public let pieceType: ChessPieceType = .knight
	public let notationLetters: [Character] = ["N", "S"]
	
	public func possibleMoves(from position: Vec2<Int>, board: [[ChessPiece?]], role: ChessRole, firstMove: Bool) -> [Vec2<Int>] {
		return [
			Vec2(x: -2, y: -1), Vec2(x: -1, y: -2),
			Vec2(x: 1, y: -2), Vec2(x: 2, y: -1),
			Vec2(x: 2, y: 1), Vec2(x: 1, y: 2),
			Vec2(x: -1, y: 2), Vec2(x: -2, y: 1)
		].map { position + $0 }
	}
}
