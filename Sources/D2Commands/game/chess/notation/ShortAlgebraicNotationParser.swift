import D2Utils

/**
 * The regular expression that matches a string in short algebraic notation.
 * 
 * 1. group: Piece letter
 * 2. group: The origin rank if needed to resolve ambiguities
 * 3. group: The origin file if needed to resolve ambiguities
 * 4. group: 'x' if the move is a capture
 * 5. group: The destination file
 * 6. group: The destination rank
 * 7. group: The promoted piece, if present
 * 8. group: '+' if the move results in a check, '#' if the move results in a checkmate
 * 9. group: 'e. p.' if the move is an en-passant
 */
fileprivate let notationRegex = try! Regex(from: "([A-Z]?)([a-h]?)([1-8])?(x?)([a-h])([1-8])(=?[A-Z])?([\\+#]?)(?:\\s+(e.p.))?")
fileprivate let shortCastlingRegex = try! Regex(from: "(?:0-0)|(?:O-O)")
fileprivate let longCastlingRegex = try! Regex(from: "(?:0-0)|(?:O-O)")

struct ShortAlgebraicNotationParser: ChessNotationParser {
	func parse(_ notation: String) -> ParsedChessMove {
		// TODO
		return ParsedChessMove(piece: EmptyPiece(), origin: Vec2(x: 0, y: 0), destination: Vec2(x: 0, y: 0))
	}
}
