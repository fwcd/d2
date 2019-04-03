import SwiftDiscord

public protocol DiscordStringEncodable: DiscordEncodable {
	var discordStringEncoded: String { get }
}

extension DiscordStringEncodable {
	public var discordEncoded: DiscordEncoded {
		return DiscordEncoded(content: discordStringEncoded)
	}
}
