import D2Graphics

public struct UnoBoard: DiscordImageEncodable {
	public var deck = UnoDeck()
	public var discardPile = [UnoCard]()
	public var discordImageEncoded: Image? { return createImage() }
	
	private func createImage() -> Image? {
		do {
			let img = try Image(width: 100, height: 300)
			var graphics = CairoGraphics(fromImage: img)
			
			// TODO
			return img
		} catch {
			print("Error while creating uno card image: \(error)")
			return nil
		}
	}
}
