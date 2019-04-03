import D2Utils

/**
 * The regular expression that matches a string in short algebraic notation.
 * 
 * 1. group: Piece letter
 * 2. group: The origin file if needed to resolve ambiguities
 * 3. group: The origin rank if needed to resolve ambiguities
 * 4. group: 'x' if the move is a capture
 * 5. group: The destination file
 * 6. group: The destination rank
 * 7. group: The promotion piece, if present
 * 8. group: '+' if the move results in a check, '#' if the move results in a checkmate
 * 9. group: 'e. p.' if the move is an en-passant
 */
fileprivate let notationRegex = try! Regex(from: "([A-Z]?)([a-h]?)([1-8])?(x?)([a-h])([1-8])(=?[A-Z])?([\\+#]?)(?:\\s+(e.\\s*p.))?")
fileprivate let shortCastlingRegex = try! Regex(from: "(?:0-0)|(?:O-O)")
fileprivate let longCastlingRegex = try! Regex(from: "(?:0-0-0)|(?:O-O-O)")

struct ShortAlgebraicNotationParser: ChessNotationParser {
	func parse(_ notation: String) -> ChessMove? {
		if longCastlingRegex.matchCount(in: notation) > 0 {
			return ChessMove(castlingType: .long)
		} else if shortCastlingRegex.matchCount(in: notation) > 0 {
			return ChessMove(castlingType: .short)
		} else if let parsed = notationRegex.firstGroups(in: notation) {
			return ChessMove(
				pieceType: parsed[1].nilIfEmpty.flatMap { pieceOf(letter: Character($0))?.pieceType } ?? .pawn,
				originX: parsed[2].nilIfEmpty.flatMap { xOf(file: Character($0)) },
				originY: parsed[3].nilIfEmpty.map { yOf(rank: Int($0)!) },
				isCapture: !parsed[4].isEmpty,
				destinationX: parsed[5].nilIfEmpty.flatMap { xOf(file: Character($0)) },
				destinationY: parsed[6].nilIfEmpty.map { yOf(rank: Int($0)!) },
				promotionPieceType: parsed[7].nilIfEmpty.flatMap { pieceOf(letter: Character($0))?.pieceType },
				checkType: parseRaw(checkType: parsed[8]),
				isEnPassant: !parsed[9].isEmpty
			)
		} else {
			return nil
		}
	}
}
