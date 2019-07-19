import D2MessageIO
import SwiftDiscord

// TO Discord conversions

extension Message {
	var usingDiscordAPI: DiscordMessage {
		return DiscordMessage(
			content: content,
			embed: embeds.first?.usingDiscordAPI,
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

// FROM Discord conversions

extension DiscordMessage {
	var usingMessageIO: Message {
		return Message(
			content: content,
			embeds: embeds.map { $0.usingMessageIO },
			attachments: attachments.map { $0.usingMessageIO }
		)
	}
}

extension DiscordAttachment {
	var usingMessageIO: Message.Attachment {
		return Message.Attachment(
			id: id.usingMessageIO,
			filename: filename,
			size: size,
			url: url,
			width: width,
			height: height
		)
	}
}
