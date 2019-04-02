import D2Utils

public struct Pawn: ChessPiece {
	public let pieceType: ChessPieceType = .pawn
	public let notationLetters: [Character] = []
	
	// TODO: En passant and promotion
	
	public func possibleMoves(from position: Vec2<Int>, board: [[ColoredPieceType?]], role: ChessRole, firstMove: Bool) -> [ChessMove] {
		let captureMoves: [Vec2<Int>] = [position + Vec2(x: -1, y: 1), position + Vec2(x: 1, y: 1)]
		var forwardMoves: [Vec2<Int>] = [position + Vec2(y: 1)]
		
		if firstMove {
			forwardMoves.append(position + Vec2(y: 2))
		}
		
		return forwardMoves.filter { board.piece(at: $0) == nil }.map { ChessMove(
			pieceType: pieceType,
			color: role,
			originX: position.x,
			originY: position.y,
			isCapture: false,
			destinationX: $0.x,
			destinationY: $0.y,
			isEnPassant: false
		) } + captureMoves.filter { board.piece(at: $0)?.color == role.opponent }.map { ChessMove(
			pieceType: pieceType,
			color: role,
			originX: position.x,
			originY: position.y,
			isCapture: true,
			destinationX: $0.x,
			destinationY: $0.y,
			isEnPassant: false
		) }
	}
}
