import D2Utils

public struct Pawn: ChessPiece {
	public let pieceType: ChessPieceType = .pawn
	public let notationLetters: [Character] = []
	public let blackResourcePng: String = "Resources/chess/blackPawn.png"
	public let whiteResourcePng: String = "Resources/chess/whitePawn.png"
	
	public func possibleMoves(from position: Vec2<Int>, board: [[BoardPieceType?]], role: ChessRole, moved: Bool, isInCheck: Bool) -> [ChessMove] {
		let direction: Int = moveYDirection(for: role)
		let captureMoves: [Vec2<Int>] = [position + Vec2(x: -1, y: direction), position + Vec2(x: 1, y: direction)]
		var forwardMoves: [Vec2<Int>] = [position + Vec2(y: direction)]
		
		if !moved {
			forwardMoves.append(position + Vec2(y: 2 * direction))
		}
		
		return forwardMoves.filter { board.piece(at: $0) == nil }.flatMap { dest -> [ChessMove] in
			let isPromotion = isFinalRank(y: dest.y, for: role, totalRanks: board.count)
			let promotionPieceTypes: [ChessPieceType?] = isPromotion ? ChessPieceType.allCases : [nil]
			return promotionPieceTypes
				.map { ChessMove(
					pieceType: pieceType,
					color: role,
					originX: position.x,
					originY: position.y,
					isCapture: false,
					destinationX: dest.x,
					destinationY: dest.y,
					promotionPieceType: $0,
					isEnPassant: false
				) }
		} + captureMoves.filter { canCapture($0, board: board, role: role) }.map {
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
	
	private func isFinalRank(y: Int, for role: ChessRole, totalRanks: Int) -> Bool {
		return ((y == 0) && (role == .white)) || ((y == (totalRanks - 1)) && (role == .black))
	}
	
	private func moveYDirection(for role: ChessRole) -> Int {
		return (role == .black) ? 1 : -1
	}
	
	private func canCapture(_ destination: Vec2<Int>, board: [[BoardPieceType?]], role: ChessRole) -> Bool {
		return (board.piece(at: destination)?.color == role.opponent) || canPerformEnPassant(at: destination, board: board, role: role)
	}
	
	private func canPerformEnPassant(at destination: Vec2<Int>, board: [[BoardPieceType?]], role: ChessRole) -> Bool {
		let enPassantPos = destination + Vec2(y: moveYDirection(for: role.opponent))
		guard enPassantPos.y == 3 || enPassantPos.y == 4 else { return false }
		
		let captured = board.piece(at: enPassantPos)
		return captured?.pieceType == .pawn && captured?.color == role.opponent && captured?.moveCount == 1
	}
}
