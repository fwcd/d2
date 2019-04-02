public struct BoardPiece {
	public let color: ChessRole
	public let piece: ChessPiece
	public var moved: Bool
	
	public var asPieceType: BoardPieceType { return BoardPieceType(color, piece.pieceType, moved: moved) }
	public var resourcePng: String { return (color == .white) ? piece.whiteResourcePng : piece.blackResourcePng }
	
	public init(_ color: ChessRole, _ piece: ChessPiece, moved: Bool = false) {
		self.color = color
		self.piece = piece
		self.moved = moved
	}
}
