import SwiftDiscord

extension DiscordTextChannel {
	public func send(_ message: String) {
		send(DiscordMessage(content: message))
	}
	
	public func send(embed: DiscordEmbed) {
		send(DiscordMessage(fromEmbed: embed))
	}
	
	public func send(image: Image) throws {
		send(try DiscordMessage(fromImage: image))
	}
}

extension DiscordMessage {
	public init(fromEmbed embed: DiscordEmbed) {
		self.init(content: "", embed: embed)
	}
	
	public init(fromImage image: Image) throws {
		self.init(content: "", files: [
			DiscordFileUpload(data: try image.pngEncoded(), filename: "image.png", mimeType: "image/png")
		])
	}
}
