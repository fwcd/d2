import D2Utils

fileprivate let cardRegex = try! Regex(from: "(\\S+)\\s+(\\S+)")
fileprivate let cardWithColorRegex = try! Regex(from: "(\\S+)\\s+(\\S+)\\s+(\\S+)")

public struct UnoMove: GameMove, Hashable {
	public let card: UnoCard?
	public let drawsCard: Bool
	public let nextColor: UnoColor?
	
	public init(playing card: UnoCard? = nil, drawingCard drawsCard: Bool = false, pickingColor nextColor: UnoColor? = nil) {
		self.card = card
		self.drawsCard = drawsCard
		self.nextColor = nextColor
	}
	
	public init(fromString str: String) throws {
		if str == "draw" {
			self.init(drawingCard: true)
		} else if let cardWithColorArgs = cardWithColorRegex.firstGroups(in: str) {
			if let card = UnoMove.parse(cardArgs: cardWithColorArgs.dropLast()), let nextColor = UnoColor(rawValue: cardWithColorArgs[3]) {
				self.init(playing: card, pickingColor: nextColor)
			} else {
				throw GameError.invalidMove("Unrecognized arguments, try: `[card color] [card label] [chosen color]` or `[card label] [card color] [chosen color]` with colors in `\(UnoColor.allCases.map { $0.rawValue })` and as a label either a number or `skip/reverse/drawTwo/wild/wildDrawFour`")
			}
		} else if let cardArgs = cardRegex.firstGroups(in: str) {
			if let card = UnoMove.parse(cardArgs: cardArgs) {
				self.init(playing: card)
			} else {
				throw GameError.invalidMove("Unrecognized arguments, try: `[card color] [card label]` or `[card label] [card color]` with color in `\(UnoColor.allCases.map { $0.rawValue })` and as a label either a number or `skip/reverse/drawTwo/wild/wildDrawFour`")
			}
		} else {
			throw GameError.invalidMove("Your move `\(str)` is invalid.")
		}
	}
	
	private static func parse(cardArgs: [String]) -> UnoCard? {
		return UnoMove.parse(rawColor: cardArgs[1], rawLabel: cardArgs[2])
			?? UnoMove.parse(rawColor: cardArgs[2], rawLabel: cardArgs[1])
	}
	
	private static func parse(rawColor: String, rawLabel: String) -> UnoCard? {
		guard let color = UnoColor(rawValue: rawColor) else { return nil }
		
		if let n = Int(rawLabel) {
			return UnoCard(color: color, label: .number(n))
		} else if let label = UnoCardLabel.of(actionLabel: rawLabel) {
			return UnoCard(color: color, label: label)
		} else {
			return nil
		}
	}
}
