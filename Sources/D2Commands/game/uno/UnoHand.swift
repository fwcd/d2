import Utils
import Graphics

public struct UnoHand: RichValueConvertible {
    public var cards: [UnoCard]
    public var isEmpty: Bool { return cards.isEmpty }
    public var asRichValue: RichValue { return cards
        .compactMap { $0.image }
        .horizontallyImageJoined()
        .map { RichValue.image($0) }
        ?? .none }
}
