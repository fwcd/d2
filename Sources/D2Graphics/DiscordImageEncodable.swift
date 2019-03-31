import SwiftDiscord

public protocol DiscordImageEncodable: DiscordEncodable {
	var discordImageEncoded: Image { get }
}

extension DiscordImageEncodable {
	public var discordMessageEncoded: DiscordMessage {
		do {
			return try DiscordMessage(fromImage: discordImageEncoded)
		} catch {
			return DiscordMessage(content: "Error: Could not encode image")
		}
	}
}
