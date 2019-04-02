import D2Utils

public struct Pawn: ChessPiece {
	public let pieceType: ChessPieceType = .pawn
	public let notationLetters: [Character] = []
	public let blackResourcePng: String = "Resources/chess/blackPawn.png"
	public let whiteResourcePng: String = "Resources/chess/whitePawn.png"
	
	// TODO: En passant and promotion
	
	public func possibleMoves(from position: Vec2<Int>, board: [[BoardPieceType?]], role: ChessRole, moved: Bool) -> [ChessMove] {
		let direction: Int = (role == .black) ? 1 : -1
		let captureMoves: [Vec2<Int>] = [position + Vec2(x: -1, y: direction), position + Vec2(x: 1, y: direction)]
		var forwardMoves: [Vec2<Int>] = [position + Vec2(y: direction)]
		
		if !moved {
			forwardMoves.append(position + Vec2(y: 2 * direction))
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
