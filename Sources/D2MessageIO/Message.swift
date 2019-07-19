import Foundation

public struct Message: Codable, ExpressibleByStringLiteral {
	public let content: String
	public let embeds: [Embed]
	public let files: [FileUpload]
	public let attachments: [Attachment]
	public let tts: Bool
	
	public init(content: String, embed: Embed? = nil, files: [FileUpload] = [], tts: Bool = false) {
		self.init(content: content, embeds: embed.map { [$0] } ?? [], files: files, tts: tts)
	}
	
	public init(content: String, embeds: [Embed] = [], files: [FileUpload] = [], attachments: [Attachment] = [], tts: Bool = false) {
		self.content = content
		self.embeds = embeds
		self.files = files
		self.attachments = attachments
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
}
