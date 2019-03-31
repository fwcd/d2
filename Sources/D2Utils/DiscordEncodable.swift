import SwiftDiscord

public protocol DiscordEncodable {
	var discordMessageEncoded: DiscordMessage { get }
}
