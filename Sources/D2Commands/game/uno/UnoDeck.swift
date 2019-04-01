public struct UnoDeck: Hashable {
	public private(set) var cards: [UnoCard]
	public var isEmpty: Bool { return cards.isEmpty }
	
	public init() {
		cards = UnoColor.allCases.flatMap {
			color in (1...9).map { UnoCard(color: color, label: .number($0)) } + [
				UnoCard(color: color, label: .skip),
				UnoCard(color: color, label: .reverse),
				UnoCard(color: color, label: .drawTwo),
				UnoCard(color: color, label: .wild),
				UnoCard(color: color, label: .wildDrawFour)
			]
		}
	}
	
	public mutating func drawRandomCard() -> UnoCard? {
		return drawRandomCards(count: 1).first
	}
	
	public mutating func drawRandomCards(count: Int) -> [UnoCard] {
		var removed = [UnoCard]()
		
		for _ in 0..<count {
			removed.append(cards.remove(at: Int.random(in: 0..<cards.count)))
		}
		
		return removed
	}
}
