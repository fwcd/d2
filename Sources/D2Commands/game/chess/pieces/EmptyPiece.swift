import D2Utils

public struct EmptyPiece: ChessPiece {
	public let notationLetters: [Character] = []
	
	public func possibleMoves(from position: Vec2<Int>, board: [[ChessPiece?]]) -> [Vec2<Int>] {
		return []
	}
}
