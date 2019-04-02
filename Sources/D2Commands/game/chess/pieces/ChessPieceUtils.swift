import D2Utils

func createPiece(_ pieceType: ChessPieceType) -> ChessPiece {
	switch pieceType {
		case .pawn: return Pawn()
		case .knight: return Knight()
		case .bishop: return Bishop()
		case .queen: return Queen()
		case .king: return King()
		case .rook: return Rook()
	}
}

func pieceOf(letter: Character) -> ChessPiece? {
	guard let (piece, _) = (ChessPieceType.allCases
		.map { createPiece($0) }
		.map { ($0, $0.notationLetters.firstIndex(of: letter)) }
		.filter { $0.1 != nil }
		.min { $0.1! < $1.1! }) else { return nil }
	return piece
}

func neighborFields() -> [Vec2<Int>] {
	return (0..<3)
		.flatMap { row in (0..<3).map { Vec2(x: $0, y: row) } }
		.filter { $0.x != 0 || $0.y != 0 }
}

func moves(into direction: Vec2<Int>, from position: Vec2<Int>, by pieceType: ChessPieceType, color: ChessRole, board: [[ColoredPieceType?]]) -> [ChessMove] {
	var moves = [ChessMove]()
	var current = position + direction
	
	while board.isInBounds(current) && board.piece(at: current) == nil {
		moves.append(ChessMove(
			pieceType: pieceType,
			color: color,
			originX: position.x,
			originY: position.y,
			isCapture: false,
			destinationX: current.x,
			destinationY: current.y,
			isEnPassant: false
		))
		current = current + direction
	}
	
	if board.piece(at: current) != nil {
		moves.append(ChessMove(
			pieceType: pieceType,
			color: color,
			originX: position.x,
			originY: position.y,
			destinationX: current.x,
			destinationY: current.y,
			isEnPassant: false
		))
	}
	
	return moves
}

extension Array where Element == [ColoredPieceType?] {
	func piece(at position: Vec2<Int>) -> ColoredPieceType? {
		guard isInBounds(position) else { return nil }
		return self[position.y][position.x]
	}
	
	func isInBounds(_ position: Vec2<Int>) -> Bool {
		guard !isEmpty else { return false }
		return position.x >= 0 && position.y >= 0 && position.x < self[0].count && position.y < count
	}
}
