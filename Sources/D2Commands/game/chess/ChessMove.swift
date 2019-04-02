import D2Utils

public struct ChessMove: Hashable {
	public let pieceType: ChessPieceType?
	public let originX: Int?
	public let originY: Int?
	public let isCapture: Bool?
	public let destinationX: Int?
	public let destinationY: Int?
	public let promotionPieceType: ChessPieceType?
	public let checkType: CheckType?
	public let isEnPassant: Bool?
	public let castlingType: CastlingType?
	
	init(
		pieceType: ChessPieceType? = nil,
		originX: Int? = nil,
		originY: Int? = nil,
		isCapture: Bool? = nil,
		destinationX: Int? = nil,
		destinationY: Int? = nil,
		promotionPieceType: ChessPieceType? = nil,
		checkType: CheckType? = nil,
		isEnPassant: Bool? = nil,
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
	
	func matches(move: ChessMove) -> Bool {
		return (pieceType == nil || move.pieceType == nil || pieceType == move.pieceType)
			&& (originX == nil || move.originX == nil || originX == move.originX)
			&& (originY == nil || move.originY == nil || originY == move.originY)
			&& (isCapture == nil || move.isCapture == nil || isCapture == move.isCapture)
			&& (destinationX == nil || move.destinationX == nil || destinationX == move.destinationX)
			&& (destinationY == nil || move.destinationY == nil || destinationY == move.destinationY)
			&& (promotionPieceType == nil || move.promotionPieceType == nil || promotionPieceType == move.promotionPieceType)
			&& (checkType == nil || move.checkType == nil || checkType == move.checkType)
			&& (isEnPassant == nil || move.isEnPassant == nil || isEnPassant == move.isEnPassant)
			&& (castlingType == nil || move.castlingType == nil || castlingType == move.castlingType)
	}
}
