import Logging
import D2Utils
import D2Graphics

fileprivate let log = Logger(label: "UnoBoard")

fileprivate struct PileCard {
	let card: UnoCard
	let rotation: Double
}

public struct UnoBoard: RichValueConvertible {
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
	
	private func createImage() -> Image? {
		do {
			let intSize = Vec2<Int>(x: 200, y: 200)
			let center = (intSize / 2).asDouble
			let img = try Image(fromSize: intSize)
			var graphics = CairoGraphics(fromImage: img)
			
			for card in discardPile {
				if let cardImage = card.card.image {
					graphics.draw(cardImage, at: center - (cardImage.size.asDouble / 2), rotation: card.rotation)
				}
			}
			
			return img
		} catch {
			log.warning("Error while creating uno card image: \(error)")
			return nil
		}
	}
}
