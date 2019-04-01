import D2Utils

public struct NotationChessMove: GameMove, Hashable {
	private let shortNotation: String
	
	public init(fromString shortNotation: String) throws {
		self.shortNotation = shortNotation
	}
	
	init(fromParsed parsedMove: ParsedChessMove) {
		shortNotation = ShortAlgebraicNotationWriter().toNotation(parsedMove)
	}
	
	func parse() -> ParsedChessMove {
		return ShortAlgebraicNotationParser().parse(shortNotation)
	}
}
