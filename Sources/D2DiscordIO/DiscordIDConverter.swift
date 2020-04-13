import D2MessageIO
import SwiftDiscord

// TO Discord conversions

extension ID: DiscordAPIConvertible {
	public var usingDiscordAPI: Snowflake {
		guard let v = UInt64(value) else {
			fatalError("Tried to convert non-Discord ID to Discord API representation: \(self)")
		}
		return Snowflake(rawValue: v)
	}
}

// FROM Discord conversions

extension Snowflake: MessageIOConvertible {
	public var usingMessageIO: ID {
		return ID(String(rawValue), clientName: discordClientName)
	}
}
