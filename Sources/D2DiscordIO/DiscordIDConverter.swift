import D2MessageIO
import SwiftDiscord

// TO Discord conversions

extension ID: DiscordAPIConvertible {
	public var usingDiscordAPI: Snowflake {
		guard clientName == discordClientName else {
			fatalError("Tried to convert non-Discord ID to Discord API representation: \(self)")
		}
		return base(as: Snowflake.self)
	}
}

// FROM Discord conversions

extension Snowflake: MessageIOConvertible {
	public var usingMessageIO: ID {
		return ID(self, clientName: discordClientName)
	}
}
