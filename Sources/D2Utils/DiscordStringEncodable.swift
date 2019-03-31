import SwiftDiscord

public protocol DiscordStringEncodable: DiscordEncodable {
	var discordStringEncoded: String { get }
}

extension DiscordStringEncodable {
	public var discordMessageEncoded: DiscordMessage {
		return DiscordMessage(content: discordStringEncoded)
	}
}
