import D2Utils

struct ParsedChessMove {
	let piece: ChessPiece?
	let originX: Int?
	let originY: Int?
	let isCapture: Bool
	let destinationX: Int?
	let destinationY: Int?
	let promotionPiece: ChessPiece?
	let checkType: CheckType?
	let isEnPassant: Bool
	let castlingType: CastlingType?
	
	init(
		piece: ChessPiece? = nil,
		originX: Int? = nil,
		originY: Int? = nil,
		isCapture: Bool = false,
		destinationX: Int? = nil,
		destinationY: Int? = nil,
		promotionPiece: ChessPiece? = nil,
		checkType: CheckType? = nil,
		isEnPassant: Bool = false,
		castlingType: CastlingType? = nil
	) {
		self.piece = piece
		self.originX = originX
		self.originY = originY
		self.isCapture = isCapture
		self.destinationX = destinationX
		self.destinationY = destinationY
		self.promotionPiece = promotionPiece
		self.checkType = checkType
		self.isEnPassant = isEnPassant
		self.castlingType = castlingType
	}
}
