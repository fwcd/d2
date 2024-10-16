import Logging
import Utils
@preconcurrency import CairoGraphics

fileprivate let log = Logger(label: "D2Commands.UnoBoard")

fileprivate struct PileCard: Sendable {
    let card: UnoCard
    let rotation: Double
}

public struct UnoBoard: RichValueConvertible, Sendable {
    public var deck = UnoDeck()
    private var discardPile = [PileCard]()
    public var asRichValue: RichValue { return createImage().map { RichValue.image($0) } ?? .none }
    public var lastDiscarded: UnoCard? { return discardPile.last.map { $0.card } }
    public var topColor: UnoColor? = nil
    public var topColorMatchesCard: Bool { return topColor == lastDiscarded?.color }

    public mutating func push(card: UnoCard) {
        let angle = Double.pi / 8
        discardPile.append(PileCard(
            card: card,
            rotation: Double.random(in: -angle..<angle)
        ))
        topColor = card.color
    }

    private func createImage() -> CairoImage? {
        do {
            let intSize = Vec2<Int>(x: 200, y: 200)
            let center = (intSize / 2).asDouble
            let img = try CairoImage(size: intSize)
            let graphics = CairoContext(image: img)

            for card in discardPile {
                if let cardImage = card.card.image {
                    graphics.draw(image: cardImage, at: center - (cardImage.size.asDouble / 2), rotation: card.rotation)
                }
            }

            return img
        } catch {
            log.warning("Error while creating uno card image: \(error)")
            return nil
        }
    }
}
