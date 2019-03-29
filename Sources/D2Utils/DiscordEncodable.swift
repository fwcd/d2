import SwiftDiscord

public protocol DiscordEncodable {
	var discordMessageEncoded: DiscordMessage { get }
	var discordStringEncoded: String { get }
}

extension DiscordEncodable {
	public var discordMessageEncoded: DiscordMessage {
		return DiscordMessage(content: discordStringEncoded)
	}
}
