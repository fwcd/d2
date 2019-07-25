import SwiftDiscord

/**
 * Parses Discord messages into rich values.
 */
public struct DiscordMessageParser {
	public func parse(message: DiscordMessage) -> RichValue {
		// TODO
		return .text(message.content)
	}
}
