import D2MessageIO
import SwiftDiscord

// TO Discord conversions

extension ID: DiscordAPIConvertible {
	var usingDiscordAPI: Snowflake {
		return Snowflake(rawValue)
	}
}

// FROM Discord conversions

extension Snowflake: MessageIOConvertible {
	var usingMessageIO: ID {
		return ID(rawValue)
	}
}
