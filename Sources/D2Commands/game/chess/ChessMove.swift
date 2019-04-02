import D2Utils

struct ChessMove: Hashable {
	let pieceType: ChessPieceType?
	let originX: Int?
	let originY: Int?
	let isCapture: Bool
	let destinationX: Int?
	let destinationY: Int?
	let promotionPieceType: ChessPieceType?
	let checkType: CheckType?
	let isEnPassant: Bool
	let castlingType: CastlingType?
	
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
