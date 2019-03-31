import D2Graphics

public struct UnoBoard: DiscordImageEncodable {
	public private(set) var deck = UnoDeck()
	public private(set) var discardPile = [UnoCard]()
	public var discordImageEncoded: Image? { return createImage() }
	
	public mutating func push(card: UnoCard) {
		discardPile.append(card)
	}
	
	private func createImage() -> Image? {
		do {
			let img = try Image(width: 100, height: 100)
			var graphics = CairoGraphics(fromImage: img)
			
			// TODO
			return img
		} catch {
			print("Error while creating uno card image: \(error)")
			return nil
		}
	}
}
