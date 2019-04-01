public struct ColoredPiece {
	public let color: ChessRole
	public let piece: ChessPiece
	public var asPieceType: ColoredPieceType { return ColoredPieceType(color, piece.pieceType) }
	
	public init(_ color: ChessRole, _ piece: ChessPiece) {
		self.color = color
		self.piece = piece
	}
}
