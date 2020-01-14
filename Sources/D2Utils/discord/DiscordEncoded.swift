import SwiftDiscord

public struct DiscordEncoded: DiscordMessageLikeInitializable {
	public let content: String
	public let embed: DiscordEmbed?
	public let files: [DiscordFileUpload]
	public let tts: Bool
	
	public var asMessage: DiscordMessage {
		return DiscordMessage(content: content, embed: embed, files: files, tts: tts)
	}
	
	public init(content: String = "", embed: DiscordEmbed? = nil, files: [DiscordFileUpload] = [], tts: Bool = false) {
		self.content = content
		self.embed = embed
		self.files = files
		self.tts = tts
	}
}
