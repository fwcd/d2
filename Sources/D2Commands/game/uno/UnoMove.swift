import D2Utils

fileprivate let cardRegex = try! Regex(from: "(\\S+)\\s+(\\S+)")

public struct UnoMove: GameMove, Hashable {
	public let card: UnoCard?
	public let drawsCard: Bool
	
	public init(playing card: UnoCard? = nil, drawingCard drawsCard: Bool = false) {
		self.card = card
		self.drawsCard = drawsCard
	}
	
	public init(fromString str: String) throws {
		if str == "draw" {
			self.init(drawingCard: true)
		} else if let cardArgs = cardRegex.firstGroups(in: str) {
			if let card = UnoMove.parse(rawColor: cardArgs[1], rawLabel: cardArgs[2]) {
				self.init(playing: card)
			} else if let card = UnoMove.parse(rawColor: cardArgs[2], rawLabel: cardArgs[1]) {
				self.init(playing: card)
			} else {
				throw GameError.invalidMove("Unrecognized arguments, try: `[color] [label]` or `[label] [color]` with color in `\(UnoColor.allCases.map { $0.rawValue })` and as a label either a number or `skip/reverse/drawTwo/wild/wildDrawFour`")
			}
		} else {
			throw GameError.invalidMove("Your move `\(str)` is invalid.")
		}
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
