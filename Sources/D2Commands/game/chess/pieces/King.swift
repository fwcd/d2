import D2Utils

public struct King: ChessPiece {
	public let notationLetters: [Character] = ["K"]
	
	private func neighbors(of position: Vec2<Int>) -> [Vec2<Int>] {
		return (0..<3)
			.flatMap { row in (0..<3).map { Vec2(x: $0, y: row) } }
			.filter { $0.x != 0 || $0.y != 0 }
	}
	
	public func possibleMoves(from position: Vec2<Int>, board: [[ChessPiece?]]) -> [Vec2<Int>] {
		return neighbors(of: position)
			.map { $0 + position }
			.filter { $0.isInBounds(of: board) }
	}
}
