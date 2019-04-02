import D2Utils

public struct Knight: ChessPiece {
	public let pieceType: ChessPieceType = .knight
	public let notationLetters: [Character] = ["N", "S"]
	
	public func possibleMoves(from position: Vec2<Int>, board: [[ColoredPieceType?]], role: ChessRole, firstMove: Bool) -> [ChessMove] {
		return [
			Vec2(x: -2, y: -1), Vec2(x: -1, y: -2),
			Vec2(x: 1, y: -2), Vec2(x: 2, y: -1),
			Vec2(x: 2, y: 1), Vec2(x: 1, y: 2),
			Vec2(x: -1, y: 2), Vec2(x: -2, y: 1)
		].map { position + $0 }.map { ChessMove(
			pieceType: pieceType,
			color: role,
			originX: position.x,
			originY: position.y,
			isCapture: board.piece(at: $0) != nil,
			destinationX: $0.x,
			destinationY: $0.y,
			isEnPassant: false
		) }
	}
}
