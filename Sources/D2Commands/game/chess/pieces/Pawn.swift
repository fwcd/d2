import D2Utils

public struct Pawn: ChessPiece {
	public let pieceType: ChessPieceType = .pawn
	public let notationLetters: [Character] = []
	public let blackResourcePng: String = "Resources/chess/blackPawn.png"
	public let whiteResourcePng: String = "Resources/chess/whitePawn.png"
	
	// TODO: Promotion
	
	public func possibleMoves(from position: Vec2<Int>, board: [[BoardPieceType?]], role: ChessRole, moved: Bool, isInCheck: Bool) -> [ChessMove] {
		let direction: Int = moveYDirection(for: role)
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
		) } + captureMoves.filter { canCapture($0, board: board, role: role) }.map {
			let isEnPassant = canPerformEnPassant(at: $0, board: board, role: role)
			return ChessMove(
				pieceType: pieceType,
				color: role,
				originX: position.x,
				originY: position.y,
				isCapture: true,
				destinationX: $0.x,
				destinationY: $0.y,
				isEnPassant: isEnPassant,
				associatedCaptures: isEnPassant ? [$0 + Vec2(y: -direction)] : []
			)
		}
	}
	
	private func moveYDirection(for role: ChessRole) -> Int {
		return (role == .black) ? 1 : -1
	}
	
	private func canCapture(_ destination: Vec2<Int>, board: [[BoardPieceType?]], role: ChessRole) -> Bool {
		return (board.piece(at: destination)?.color == role.opponent) || canPerformEnPassant(at: destination, board: board, role: role)
	}
	
	private func canPerformEnPassant(at destination: Vec2<Int>, board: [[BoardPieceType?]], role: ChessRole) -> Bool {
		let captured = board.piece(at: destination + Vec2(y: moveYDirection(for: role.opponent)))
		return captured?.pieceType == .pawn && captured?.color == role.opponent && captured?.moveCount == 1
	}
}
