import D2Utils

public struct Bishop: ChessPiece {
	public let notationLetters: [Character] = []
	
	public func possibleMoves(from position: Vec2<Int>, board: [[ChessPiece?]], role: ChessRole, firstMove: Bool) -> [Vec2<Int>] {
		return [Vec2(x: -1), Vec2(x: 1), Vec2(y: -1), Vec2(y: 1)]
			.map { position + $0 }
			.flatMap { moves(into: $0, from: position, board: board) }
	}
}
