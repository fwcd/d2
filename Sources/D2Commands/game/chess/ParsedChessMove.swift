import D2Utils

struct ParsedChessMove {
	let piece: ChessPiece
	let originX: Int?
	let originY: Int?
	let destinationX: Int?
	let destinationY: Int?
	
	init(piece: ChessPiece, originX: Int? = nil, originY: Int? = nil, destinationX: Int? = nil, destinationY: Int? = nil) {
		self.piece = piece
		self.originX = originX
		self.originY = originY
		self.destinationX = destinationX
		self.destinationY = destinationY
	}
}
