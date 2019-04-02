public struct BoardPieceType {
	public let color: ChessRole
	public let pieceType: ChessPieceType
	public let moved: Bool
	
	public init(_ color: ChessRole, _ pieceType: ChessPieceType, moved: Bool) {
		self.color = color
		self.pieceType = pieceType
		self.moved = moved
	}
}
