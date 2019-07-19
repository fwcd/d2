import D2MessageIO
import SwiftDiscord

extension Message {
	var usingDiscordAPI: DiscordMessage {
		return DiscordMessage(
			content: content,
			embed: embed?.usingDiscordAPI,
			// TODO: Attachments
			tts: tts
		)
	}
}
