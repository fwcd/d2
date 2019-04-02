import D2Utils

public struct Bishop: ChessPiece {
	public let pieceType: ChessPieceType = .bishop
	public let notationLetters: [Character] = ["B", "L"]
	public let blackResourcePng: String = "Resources/chess/blackBishop.png"
	public let whiteResourcePng: String = "Resources/chess/whiteBishop.png"
	
	public func possibleMoves(from position: Vec2<Int>, board: [[ColoredPieceType?]], role: ChessRole, firstMove: Bool) -> [ChessMove] {
		return [Vec2(x: -1, y: -1), Vec2(x: 1, y: 1), Vec2(x: 1, y: -1), Vec2(x: -1, y: 1)]
			.map { position + $0 }
			.flatMap { moves(into: $0, from: position, by: pieceType, color: role, board: board) }
	}
}
