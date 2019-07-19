import Foundation

public struct Message: Codable, ExpressibleByStringLiteral {
	public let content: String
	public let embeds: [Embed]
	public let files: [Message.FileUpload]
	public let tts: Bool
	
	public let attachments: [Attachment]
	public let activity: MessageActivity?
	public let application: MessageApplication?
	public let author: User?
	public let channelId: ChannelID?
	public let editedTimestamp: Date?
	public let id: MessageID?
	public let mentionEveryone: Bool
	public let mentionRoles: [RoleID]
	public let mentions: [User]
	public let nonce: ID?
	public let pinned: Bool
	public let reactions: [Reaction]
	public let timestamp: Date?
	public let type: MessageType?
	
	public var embed: Embed? { return embeds.first }
	
	/** Initializer intended for messages that are to be sent. */
	public init(content: String, embed: Embed? = nil, files: [FileUpload] = [], tts: Bool = false) {
		self.init(content: content, embeds: embed.map { [$0] } ?? [], files: files, tts: tts)
	}
	
	/** Initializer intended for received/arbitrary messages. */
	public init(
		content: String,
		embeds: [Embed] = [],
		files: [FileUpload] = [],
		tts: Bool = false,
		attachments: [Attachment] = [],
		activity: MessageActivity? = nil,
		application: MessageApplication? = nil,
		author: User? = nil,
		channelId: ChannelID? = nil,
		editedTimestamp: Date? = nil,
		id: MessageID? = nil,
		mentionEveryone: Bool = false,
		mentionRoles: [RoleID] = [],
		mentions: [User] = [],
		nonce: ID? = nil,
		pinned: Bool = false,
		reactions: [Reaction] = [],
		timestamp: Date? = nil,
		type: MessageType? = nil
	) {
		self.content = content
		self.embeds = embeds
		self.files = files
		self.tts = tts
		self.attachments = attachments
		self.activity = activity
		self.application = application
		self.author = author
		self.channelId = channelId
		self.editedTimestamp = editedTimestamp
		self.id = id
		self.mentionEveryone = mentionEveryone
		self.mentionRoles = mentionRoles
		self.mentions = mentions
		self.nonce = nonce
		self.pinned = pinned
		self.reactions = reactions
		self.timestamp = timestamp
		self.type = type
	}
	
	public init(stringLiteral value: String) {
		self.init(content: value)
	}
	
	public struct FileUpload: Codable {
		public let data: Data
		public let filename: String
		public let mimeType: String
		
		public init(data: Data, filename: String, mimeType: String) {
			self.data = data
			self.filename = filename
			self.mimeType = mimeType
		}
	}
	
	public struct Attachment: Codable {
		public let id: AttachmentID
		public let filename: String
		public let size: Int
		public let url: URL?
		public let width: Int?
		public let height: Int?
		
		public init(id: AttachmentID, filename: String, size: Int, url: URL? = nil, width: Int? = nil, height: Int? = nil) {
			self.id = id
			self.filename = filename
			self.size = size
			self.url = url
			self.width = width
			self.height = height
		}
	}
	
	public struct MessageActivity: Codable {
		public let type: ActivityType
		public let partyId: String?
		
		public init(type: ActivityType, partyId: String? = nil) {
			self.type = type
			self.partyId = partyId
		}
		
		public enum ActivityType: Int, Codable {
			case join
			case spectate
			case listen
			case joinRequest
		}
	}
	
	public struct MessageApplication: Codable {
		public let id: ID
		public let coverImage: String
		public let description: String
		public let icon: String
		public let name: String
		
		public init(id: ID, coverImage: String, description: String, icon: String, name: String) {
			self.id = id
			self.coverImage = coverImage
			self.description = description
			self.icon = icon
			self.name = name
		}
	}
	
	public struct Reaction: Codable {
		public let count: Int
		public let me: Bool
		public let emoji: Emoji
		
		public init(count: Int, me: Bool, emoji: Emoji) {
			self.count = count
			self.me = me
			self.emoji = emoji
		}
	}
	
	public enum MessageType: Int, Codable {
        case `default`
        case recipientAdd
        case recipientRemove
        case call
        case channelNameChange
        case channelIconChange
        case channelPinnedMessage
        case guildMemberJoin
    }
}
