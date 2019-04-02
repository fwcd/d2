import D2Utils

public struct ChessMove: Hashable {
	public let pieceType: ChessPieceType?
	public let color: ChessRole?
	public let originX: Int?
	public let originY: Int?
	public let isCapture: Bool?
	public let destinationX: Int?
	public let destinationY: Int?
	public let promotionPieceType: ChessPieceType?
	public let checkType: CheckType?
	public let isEnPassant: Bool?
	public let castlingType: CastlingType?
	
	// Contains additional moves such as the rook move after castling
	// that should be performed immediately after this move.
	public let associatedMoves: [ChessMove]?
	
	public var isFullyDefined: Bool {
		return pieceType != nil
			&& color != nil
			&& originX != nil
			&& originY != nil
			&& isCapture != nil
			&& destinationX != nil
			&& destinationY != nil
			&& promotionPieceType != nil
			&& isEnPassant != nil
			&& associatedMoves != nil
	}
	
	public init(
		pieceType: ChessPieceType? = nil,
		color: ChessRole? = nil,
		originX: Int? = nil,
		originY: Int? = nil,
		isCapture: Bool? = nil,
		destinationX: Int? = nil,
		destinationY: Int? = nil,
		promotionPieceType: ChessPieceType? = nil,
		checkType: CheckType? = nil,
		isEnPassant: Bool? = nil,
		castlingType: CastlingType? = nil,
		associatedMoves: [ChessMove]? = nil
	) {
		self.pieceType = pieceType
		self.color = color
		self.originX = originX
		self.originY = originY
		self.isCapture = isCapture
		self.destinationX = destinationX
		self.destinationY = destinationY
		self.promotionPieceType = promotionPieceType
		self.checkType = checkType
		self.isEnPassant = isEnPassant
		self.castlingType = castlingType
		self.associatedMoves = associatedMoves
	}
	
	func matches(move: ChessMove) -> Bool {
		return (pieceType == nil || move.pieceType == nil || pieceType == move.pieceType)
			&& (color == nil || move.color == nil || color == move.color)
			&& (originX == nil || move.originX == nil || originX == move.originX)
			&& (originY == nil || move.originY == nil || originY == move.originY)
			&& (isCapture == nil || move.isCapture == nil || isCapture == move.isCapture)
			&& (destinationX == nil || move.destinationX == nil || destinationX == move.destinationX)
			&& (destinationY == nil || move.destinationY == nil || destinationY == move.destinationY)
			&& (promotionPieceType == nil || move.promotionPieceType == nil || promotionPieceType == move.promotionPieceType)
			&& (checkType == nil || move.checkType == nil || checkType == move.checkType)
			&& (isEnPassant == nil || move.isEnPassant == nil || isEnPassant == move.isEnPassant)
			&& (castlingType == nil || move.castlingType == nil || castlingType == move.castlingType)
			&& (associatedMoves == nil || move.associatedMoves == nil || associatedMoves == move.associatedMoves)
	}
}
