import D2Utils

public struct EmptyPiece: ChessPiece {
	public let notationLetter: Character? = nil
	
	public func reachablePositions(from position: Vec2<Int>, boardSize: Vec2<Int>) -> [Vec2<Int>] {
		return []
	}
}
