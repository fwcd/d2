import Foundation

public struct Attachment: Codable {
	public let data: Data
	public let filename: String
	public let mimeType: String
	
	public init(data: Data, filename: String, mimeType: String) {
		self.data = data
		self.filename = filename
		self.mimeType = mimeType
	}
}
