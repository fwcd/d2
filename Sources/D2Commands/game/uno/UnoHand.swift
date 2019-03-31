import D2Utils
import D2Graphics

public struct UnoHand: DiscordImageEncodable {
	public var cards = [UnoCard]()
	public var isEmpty: Bool { return cards.isEmpty }
	public var discordImageEncoded: Image? { return cards.compactMap { $0.image }.horizontallyImageJoined() }
}
