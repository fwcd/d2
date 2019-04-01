import D2Utils

public protocol ChessPiece {
	var notationLetter: Character? { get }
	
	func reachablePositions(from position: Vec2<Int>, boardSize: Vec2<Int>) -> [Vec2<Int>]
}
