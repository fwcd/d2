protocol ChessNotationWriter {
	func toNotation(_ parsedMove: ParsedChessMove) -> String
}
