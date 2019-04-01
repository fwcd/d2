import D2Utils

public struct Queen: ChessPiece {
	public let notationLetters: [Character] = ["Q"]
	
	private func moves(into direction: Vec2<Int>, from position: Vec2<Int>, board: [[ChessPiece?]]) -> [Vec2<Int>] {
		var moves = [Vec2<Int>]()
		var current = position + direction
		
		while board.isInBounds(current) && board.piece(at: current) == nil {
			moves.append(current)
			current = current + direction
		}
		
		if board.piece(at: current) != nil {
			moves.append(current)
		}
		
		return moves
	}
	
	public func possibleMoves(from position: Vec2<Int>, board: [[ChessPiece?]], role: ChessRole, firstMove: Bool) -> [Vec2<Int>] {
		return neighbors(of: position)
			.flatMap { moves(into: $0, from: position, board: board) }
	}
}
