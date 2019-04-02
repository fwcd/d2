import D2Utils

public struct King: ChessPiece {
	public let pieceType: ChessPieceType = .king
	public let notationLetters: [Character] = ["K"]
	public let blackResourcePng: String = "Resources/chess/blackKing.png"
	public let whiteResourcePng: String = "Resources/chess/whiteKing.png"
	
	// TODO: Castling
	
	public func possibleMoves(from position: Vec2<Int>, board: [[ColoredPieceType?]], role: ChessRole, firstMove: Bool) -> [ChessMove] {
		return neighbors(of: position)
			.map { $0 + position }
			.map { ChessMove(
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
