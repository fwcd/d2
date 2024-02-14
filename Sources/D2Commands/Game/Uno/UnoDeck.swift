public struct UnoDeck: Hashable {
    public private(set) var cards: [UnoCard] = generateCards()
    public var isEmpty: Bool { return cards.isEmpty }

    private static func generateCards() -> [UnoCard] {
        return UnoColor.allCases.flatMap { color in
            (0...9).map { UnoCard.number($0, color) } + [
                UnoCard.action(.skip, color),
                UnoCard.action(.reverse, color),
                UnoCard.action(.drawTwo, color),
                UnoCard.action(.wild, nil)
            ]
        } + UnoColor.allCases.flatMap { color in
            (1...9).map { UnoCard.number($0, color) } + [
                UnoCard.action(.wildDrawFour, nil)
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
