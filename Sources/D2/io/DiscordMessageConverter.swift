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
			attachments: attachments.map { $0.usingMessageIO },
			activity: activity?.usingMessageIO,
			application: application?.usingMessageIO,
			author: author.usingMessageIO,
			channelId: channelId.usingMessageIO,
			editedTimestamp: editedTimestamp,
			id: id.usingMessageIO,
			mentionEveryone: mentionEveryone,
			mentionRoles: mentionRoles.map { $0.usingMessageIO },
			mentions: mentions.map { $0.usingMessageIO },
			nonce: nonce.usingMessageIO,
			pinned: pinned,
			reactions: reactions.map { $0.usingMessageIO },
			timestamp: timestamp,
			type: type.usingMessageIO
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

extension DiscordMessage.MessageActivity {
	var usingMessageIO: Message.MessageActivity {
		return Message.MessageActivity(
			type: type.usingMessageIO,
			partyId: partyId
		)
	}
}

extension DiscordMessage.MessageActivity.ActivityType {
	var usingMessageIO: Message.MessageActivity.ActivityType {
		switch self {
			case .join: return .join
			case .spectate: return .spectate
			case .listen: return .listen
			case .joinRequest: return .joinRequest
		}
	}
}

extension DiscordMessage.MessageApplication {
	var usingMessageIO: Message.MessageApplication {
		return Message.MessageApplication(
			id: id.usingMessageIO,
			coverImage: coverImage,
			description: description,
			icon: icon,
			name: name
		)
	}
}

extension DiscordReaction {
	var usingMessageIO: Message.Reaction {
		return Message.Reaction(
			count: count,
			me: me,
			emoji: emoji.usingMessageIO
		)
	}
}

extension DiscordMessage.MessageType {
	var usingMessageIO: Message.MessageType {
		switch self {
			case .`default`: return .`default`
			case .recipientAdd: return .recipientAdd
			case .recipientRemove: return .recipientRemove
			case .call: return .call
			case .channelNameChange: return .channelNameChange
			case .channelIconChange: return .channelIconChange
			case .channelPinnedMessage: return .channelPinnedMessage
			case .guildMemberJoin: return .guildMemberJoin
		}
	}
}
