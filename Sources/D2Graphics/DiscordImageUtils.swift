import SwiftDiscord

extension DiscordTextChannel {
	public func send(image: Image) throws {
		send(try DiscordMessage(fromImage: image))
	}
}

extension DiscordMessage {
	public init(fromImage image: Image) throws {
		self.init(content: "", files: [
			DiscordFileUpload(data: try image.pngEncoded(), filename: "image.png", mimeType: "image/png")
		])
	}
}
