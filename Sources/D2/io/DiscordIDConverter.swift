import D2MessageIO
import SwiftDiscord

// TO Discord conversions

extension ID: DiscordAPIConvertible {
	public var usingDiscordAPI: Snowflake {
		return Snowflake(rawValue)
	}
}

// FROM Discord conversions

extension Snowflake: MessageIOConvertible {
	public var usingMessageIO: ID {
		return ID(rawValue)
	}
}
