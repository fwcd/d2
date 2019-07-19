import D2MessageIO
import SwiftDiscord

// TO Discord conversions

extension ID {
	var usingDiscordAPI: Snowflake {
		return Snowflake(rawValue)
	}
}

// FROM Discord conversions

extension Snowflake {
	var usingMessageIO: ID {
		return ID(rawValue)
	}
}
