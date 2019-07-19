import D2MessageIO
import SwiftDiscord

// FROM Discord conversions

extension DiscordUser {
	var usingMessageIO: User {
		return User(
			avatar: avatar,
			bot: bot,
			discriminator: discriminator,
			email: email,
			id: id.usingMessageIO,
			mfaEnabled: mfaEnabled,
			username: username,
			verified: verified
		)
	}
}
