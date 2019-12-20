import D2MessageIO
import SwiftDiscord

// TO Discord conversions

extension Message: DiscordAPIConvertible {
	public var usingDiscordAPI: DiscordMessage {
		return DiscordMessage(
			content: content,
			embed: embeds.first?.usingDiscordAPI,
			files: files.map { $0.usingDiscordAPI },
			tts: tts
		)
	}
}

extension Message.FileUpload: DiscordAPIConvertible {
	public var usingDiscordAPI: DiscordFileUpload {
		return DiscordFileUpload(data: data, filename: filename, mimeType: mimeType)
	}
}

// FROM Discord conversions

extension DiscordMessage: MessageIOConvertible {
	public var usingMessageIO: Message {
		return Message(
			content: content,
			embeds: embeds.usingMessageIO,
			attachments: attachments.usingMessageIO,
			activity: activity?.usingMessageIO,
			application: application?.usingMessageIO,
			author: author.usingMessageIO,
			channelId: channelId.usingMessageIO,
			editedTimestamp: editedTimestamp,
			id: id.usingMessageIO,
			mentionEveryone: mentionEveryone,
			mentionRoles: mentionRoles.usingMessageIO,
			mentions: mentions.usingMessageIO,
			nonce: nonce.usingMessageIO,
			pinned: pinned,
			reactions: reactions.usingMessageIO,
			timestamp: timestamp,
			type: type.usingMessageIO
		)
	}
}

extension DiscordAttachment: MessageIOConvertible {
	public var usingMessageIO: Message.Attachment {
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

extension DiscordMessage.MessageActivity: MessageIOConvertible {
	public var usingMessageIO: Message.MessageActivity {
		return Message.MessageActivity(
			type: type.usingMessageIO,
			partyId: partyId
		)
	}
}

extension DiscordMessage.MessageActivity.ActivityType: MessageIOConvertible {
	public var usingMessageIO: Message.MessageActivity.ActivityType {
		switch self {
			case .join: return .join
			case .spectate: return .spectate
			case .listen: return .listen
			case .joinRequest: return .joinRequest
		}
	}
}

extension DiscordMessage.MessageApplication: MessageIOConvertible {
	public var usingMessageIO: Message.MessageApplication {
		return Message.MessageApplication(
			id: id.usingMessageIO,
			coverImage: coverImage,
			description: description,
			icon: icon,
			name: name
		)
	}
}

extension DiscordReaction: MessageIOConvertible {
	public var usingMessageIO: Message.Reaction {
		return Message.Reaction(
			count: count,
			me: me,
			emoji: emoji.usingMessageIO
		)
	}
}

extension DiscordMessage.MessageType: MessageIOConvertible {
	public var usingMessageIO: Message.MessageType {
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
