public struct BoardPiece {
	public let color: ChessRole
	public let piece: ChessPiece
	public var moveCount: Int
	public var moved: Bool { return moveCount > 0 }
	
	public var asPieceType: BoardPieceType { return BoardPieceType(color, piece.pieceType, moveCount: moveCount) }
	public var resourcePng: String { return (color == .white) ? piece.whiteResourcePng : piece.blackResourcePng }
	
	public init(_ color: ChessRole, _ piece: ChessPiece, moveCount: Int = 0) {
		self.color = color
		self.piece = piece
		self.moveCount = moveCount
	}
}
