protocol ChessNotationParser {
	func parse(_ notation: String) -> ParsedChessMove
}
