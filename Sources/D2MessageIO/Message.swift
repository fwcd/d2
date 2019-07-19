import Foundation

public struct Message: Codable, ExpressibleByStringLiteral {
	public let content: String
	public let embeds: [Embed]
	public let files: [FileUpload]
	public let attachments: [Attachment]
	public let activity: MessageActivity?
	public let tts: Bool
	
	/** Initializer intended for messages that are to be sent. */
	public init(content: String, embed: Embed? = nil, files: [FileUpload] = [], tts: Bool = false) {
		self.init(content: content, embeds: embed.map { [$0] } ?? [], files: files, tts: tts)
	}
	
	/** Initializer intended for received/arbitrary messages. */
	public init(content: String, embeds: [Embed] = [], files: [FileUpload] = [], attachments: [Attachment] = [], activity: MessageActivity? = nil, tts: Bool = false) {
		self.content = content
		self.embeds = embeds
		self.files = files
		self.attachments = attachments
		self.activity = activity
		self.tts = tts
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
}
