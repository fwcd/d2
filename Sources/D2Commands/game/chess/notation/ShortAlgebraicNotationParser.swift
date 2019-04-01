import D2Utils

struct ShortAlgebraicNotationParser: ChessNotationParser {
	func parse(_ notation: String) -> ParsedChessMove {
		// TODO
		return ParsedChessMove(piece: EmptyPiece(), origin: Vec2(x: 0, y: 0), destination: Vec2(x: 0, y: 0))
	}
}
