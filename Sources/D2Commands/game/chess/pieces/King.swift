import D2Utils

public struct King: ChessPiece {
	public let notationLetters: [Character] = ["K"]
	
	public func reachablePositions(from position: Vec2<Int>, boardSize: Vec2<Int>) -> [Vec2<Int>] {
		return (0..<3)
			.flatMap { row in (0..<3).map { Vec2(x: $0, y: row) } }
			.filter { $0.x != 0 || $0.y != 0 }
	}
}
