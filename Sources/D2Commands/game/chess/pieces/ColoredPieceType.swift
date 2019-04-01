public struct ColoredPieceType {
	public let color: ChessRole
	public let pieceType: ChessPieceType
	
	public init(_ color: ChessRole, _ pieceType: ChessPieceType) {
		self.color = color
		self.pieceType = pieceType
	}
}
