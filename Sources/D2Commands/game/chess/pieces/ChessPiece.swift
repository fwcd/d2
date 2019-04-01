import D2Utils

public protocol ChessPiece {
	func reachablePositions(from position: Vec2<Int>, boardSize: Vec2<Int>)
}
