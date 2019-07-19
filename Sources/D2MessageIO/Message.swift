public struct Message: Codable, ExpressibleByStringLiteral {
	public let content: String
	public let embed: Embed?
	public let attachments: [Attachment]
	public let tts: Bool
	
	public init(content: String, embed: Embed? = nil, attachments: [Attachment] = [], tts: Bool = false) {
		self.content = content
		self.embed = embed
		self.attachments = attachments
		self.tts = tts
	}
	
	public init(stringLiteral value: String) {
		self.init(content: value)
	}
}
