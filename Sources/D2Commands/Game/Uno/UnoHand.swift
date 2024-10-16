import Utils
import CairoGraphics

public struct UnoHand: RichValueConvertible, Sendable {
    public var cards: [UnoCard]
    public var isEmpty: Bool { return cards.isEmpty }
    public var asRichValue: RichValue { return CairoContext.joinHorizontally(images: cards.compactMap(\.image))
        .map { RichValue.image($0) }
        ?? .none }
}
