import D2MessageIO
import SwiftDiscord

extension Message {
	var usingDiscordAPI: DiscordMessage {
		return DiscordMessage(
			content: content,
			embed: embed?.usingDiscordAPI,
			files: files.map { $0.usingDiscordAPI },
			tts: tts
		)
	}
}

extension Message.FileUpload {
	var usingDiscordAPI: DiscordFileUpload {
		return DiscordFileUpload(data: data, filename: filename, mimeType: mimeType)
	}
}
