import D2Utils

func neighbors(of position: Vec2<Int>) -> [Vec2<Int>] {
	return (0..<3)
		.flatMap { row in (0..<3).map { Vec2(x: $0, y: row) } }
		.filter { $0.x != 0 || $0.y != 0 }
}

extension Array where Element == [ChessPiece?] {
	func piece(at position: Vec2<Int>) -> ChessPiece? {
		guard isInBounds(position) else { return nil }
		return self[position.y][position.x]
	}
	
	func isInBounds(_ position: Vec2<Int>) -> Bool {
		guard !isEmpty else { return false }
		return position.x >= 0 && position.y >= 0 && position.x < self[0].count && position.y < count
	}
}
