import D2Utils

fileprivate let argsRegex = try! Regex(from: "(\\S+)\\s+(\\S+)")

public struct UnoMove: GameMove, Hashable {
	private let card: UnoCard
	
	public init(playing card: UnoCard) {
		self.card = card
	}
	
	public init(fromString str: String) throws {
		if let parsedArgs = argsRegex.firstGroups(in: str) {
			if let color = UnoColor(rawValue: parsedArgs[1]), let number = Int(parsedArgs[2]) {
				card = UnoCard(color: color, number: number)
			} else if let color = UnoColor(rawValue: parsedArgs[2]), let number = Int(parsedArgs[1]) {
				card = UnoCard(color: color, number: number)
			} else {
				throw GameError.invalidMove("Unrecognized arguments, try: `[color] [number]` or `[number] [color]`")
			}
		} else {
			throw GameError.invalidMove("Your move `\(str)` is invalid.")
		}
	}
}
