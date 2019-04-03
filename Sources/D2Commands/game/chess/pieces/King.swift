import D2Utils

public struct King: ChessPiece {
	public let pieceType: ChessPieceType = .king
	public let notationLetters: [Character] = ["K"]
	public let blackResourcePng: String = "Resources/chess/blackKing.png"
	public let whiteResourcePng: String = "Resources/chess/whiteKing.png"
	
	public func possibleMoves(from position: Vec2<Int>, board: [[BoardPieceType?]], role: ChessRole, moved: Bool) -> [ChessMove] {
		var moves = neighborFields()
			.map { $0 + position }
			.map { ChessMove(
				pieceType: pieceType,
				color: role,
				originX: position.x,
				originY: position.y,
				isCapture: board.piece(at: $0) != nil,
				destinationX: $0.x,
				destinationY: $0.y,
				isEnPassant: false
			) }
		
		if !moved {
			// Find castling moves
			moves += RookSide.allCases
				.compactMap { side in
					guard let (rookPos, rook) = locateRook(of: role, on: side, board: board) else { return nil }
					guard fieldUnoccupied(between: position, and: rookPos, board: board) else { return nil }
					guard rook.color == role && !rook.moved else { return nil }
					
					let step = (rookPos.x - position.x).signum()
					
					return ChessMove(
						pieceType: pieceType,
						color: role,
						originX: position.x,
						originY: position.y,
						isCapture: false,
						destinationX: position.x + (step * 2),
						destinationY: position.y,
						castlingType: side.asCastlingType,
						associatedMoves: [
							// The rook move
							ChessMove(
								pieceType: .rook,
								color: role,
								originX: rookPos.x,
								originY: rookPos.y,
								isCapture: false,
								destinationX: position.x + step,
								destinationY: position.y
							)
						]
					)
				}
		}
		
		return moves
	}
	
	private func locateRook(of role: ChessRole, on side: RookSide, board: [[BoardPieceType?]]) -> (Vec2<Int>, BoardPieceType)? {
		let x = (side == .kingside) ? (board[0].count - 1) : 0
		let y = (role == .white) ? (board.count - 1) : 0
		
		if let piece = board[y][x] {
			if piece.pieceType == .rook {
				return (Vec2(x: x, y: y), piece)
			}
		}
		
		return nil
	}
	
	private func fieldUnoccupied(between start: Vec2<Int>, and end: Vec2<Int>, board: [[BoardPieceType?]]) -> Bool {
		let step = Vec2(x: (end.x - start.x).signum(), y: (end.y - start.y).signum())
		var current = start + step
		
		while current != end {
			if board[current.y][current.x] != nil {
				return false
			}
			current = current + step
		}
		
		return true
	}
}
