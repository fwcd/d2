import D2Utils

fileprivate let argsRegex = try! Regex(from: "(\\S+)\\s+(\\S+)")

public struct UnoMove: GameMove, Hashable {
	public let card: UnoCard
	
	public init(playing card: UnoCard) {
		self.card = card
	}
	
	public init(fromString str: String) throws {
		if let parsedArgs = argsRegex.firstGroups(in: str) {
			if let card = UnoMove.parse(rawColor: parsedArgs[1], rawLabel: parsedArgs[2]) {
				self.init(playing: card)
			} else if let card = UnoMove.parse(rawColor: parsedArgs[2], rawLabel: parsedArgs[1]) {
				self.init(playing: card)
			} else {
				throw GameError.invalidMove("Unrecognized arguments, try: `[color] [number]` or `[number] [color]`")
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
