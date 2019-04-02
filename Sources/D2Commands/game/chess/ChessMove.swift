import D2Utils

public struct ChessMove: Hashable {
	public let pieceType: ChessPieceType?
	public let originX: Int?
	public let originY: Int?
	public let isCapture: Bool
	public let destinationX: Int?
	public let destinationY: Int?
	public let promotionPieceType: ChessPieceType?
	public let checkType: CheckType?
	public let isEnPassant: Bool
	public let castlingType: CastlingType?
	
	init(
		pieceType: ChessPieceType? = nil,
		originX: Int? = nil,
		originY: Int? = nil,
		isCapture: Bool = false,
		destinationX: Int? = nil,
		destinationY: Int? = nil,
		promotionPieceType: ChessPieceType? = nil,
		checkType: CheckType? = nil,
		isEnPassant: Bool = false,
		castlingType: CastlingType? = nil
	) {
		self.pieceType = pieceType
		self.originX = originX
		self.originY = originY
		self.isCapture = isCapture
		self.destinationX = destinationX
		self.destinationY = destinationY
		self.promotionPieceType = promotionPieceType
		self.checkType = checkType
		self.isEnPassant = isEnPassant
		self.castlingType = castlingType
	}
}
