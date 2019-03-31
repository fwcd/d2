import D2Utils
import D2Graphics

public struct UnoBoard: DiscordImageEncodable {
	public var deck = UnoDeck()
	public private(set) var discardPile = [UnoCard]()
	public var discordImageEncoded: Image? { return createImage() }
	
	public mutating func push(card: UnoCard) {
		discardPile.append(card)
	}
	
	private func createImage() -> Image? {
		do {
			let intSize = Vec2<Int>(x: 300, y: 300)
			let center = (intSize / 2).asDouble
			let img = try Image(fromSize: intSize)
			var graphics = CairoGraphics(fromImage: img)
			
			let fourthPi = Double.pi / 4
			
			for card in discardPile {
				if let cardImage = card.image {
					graphics.save()
					graphics.rotate(by: Double.random(in: -fourthPi..<fourthPi))
					graphics.draw(cardImage, at: center - (cardImage.size.asDouble / 2))
					graphics.restore()
				}
			}
			
			return img
		} catch {
			print("Error while creating uno card image: \(error)")
			return nil
		}
	}
}
