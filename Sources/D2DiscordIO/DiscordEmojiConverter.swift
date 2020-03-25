import D2MessageIO
import SwiftDiscord

// FROM Discord conversions

extension DiscordEmoji: MessageIOConvertible {
	public var usingMessageIO: Emoji {
		return Emoji(
			id: id?.usingMessageIO,
			managed: managed,
			name: name,
			requireColons: requireColons,
			roles: roles.map { $0.usingMessageIO }
		)
	}
}
