import Foundation

public struct Message: Codable, ExpressibleByStringLiteral {
	public let content: String
	public let embed: Embed?
	public let files: [FileUpload]
	public let tts: Bool
	
	public init(content: String, embed: Embed? = nil, files: [FileUpload] = [], tts: Bool = false) {
		self.content = content
		self.embed = embed
		self.files = files
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
}
