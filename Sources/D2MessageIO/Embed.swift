import Foundation

public struct Embed: Codable {
	public let title: String?
	public let description: String?
	public let author: Author?
	public let url: URL?
	public let image: Image?
	public let timestamp: Date?
	public let thumbnail: Thumbnail?
	public let color: Int?
	public let footer: Footer?
	public let fields: [Field]
	
	public init(
		title: String,
		description: String? = nil,
		author: Author? = nil,
		url: URL? = nil,
		image: Image? = nil,
		timestamp: Date? = nil,
		thumbnail: Thumbnail? = nil,
		color: Int? = nil,
		footer: Footer? = nil,
		fields: [Field] = []
	) {
		self.title = title
		self.description = description
		self.author = author
		self.url = url
		self.image = image
		self.timestamp = timestamp
		self.thumbnail = thumbnail
		self.color = color
		self.footer = footer
		self.fields = fields
	}
	
	public struct Author: Codable {
		public let name: String
		public let iconUrl: URL?
		public let url: URL?
		
		public init(name: String, iconUrl: URL? = nil, url: URL? = nil) {
			self.name = name
			self.iconUrl = iconUrl
			self.url = url
		}
	}
	
	public struct Image: Codable {
		public let url: URL
		
		public init(url: URL) {
			self.url = url
		}
	}
	
	public struct Thumbnail: Codable {
		public let url: URL
		
		public init(url: URL) {
			self.url = url
		}
	}
	
	public struct Footer: Codable {
		public let text: String
		
		public init(text: String) {
			self.text = text
		}
	}
	
	public struct Field: Codable {
		public let name: String
		public let value: String
		
		public init(name: String, value: String) {
			self.name = name
			self.value = value
		}
	}
}
