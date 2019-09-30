public struct UnoDeck: Hashable {
	public private(set) var cards: [UnoCard] = generateCards()
	public var isEmpty: Bool { return cards.isEmpty }
	
	private static func generateCards() -> [UnoCard] {
		return UnoColor.allCases.flatMap { color in
			(0...9).map { UnoCard(color: color, label: .number($0)) } + [
				UnoCard(color: color, label: .skip),
				UnoCard(color: color, label: .reverse),
				UnoCard(color: color, label: .drawTwo),
				UnoCard(color: color, label: .wild)
			]
		} + UnoColor.allCases.flatMap { color in
			(1...9).map { UnoCard(color: color, label: .number($0)) } + [
				UnoCard(color: color, label: .wildDrawFour)
			]
		}
	}
	
	public mutating func refill() {
		cards = UnoDeck.generateCards()
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
