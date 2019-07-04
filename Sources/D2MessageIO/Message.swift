public struct Message {
	public let embed: Embed?
	public let attachments: [Attachment]
	public let tts: Bool
	
	public init(embed: Embed? = nil, attachments: [Attachment] = [], tts: Bool = false) {
		self.embed = embed
		self.attachments = attachments
	}
}
