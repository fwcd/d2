protocol ChessNotationWriter {
    func toNotation(_ parsedMove: ChessMove) -> String
}
