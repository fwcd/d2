import SwiftDiscord
import D2Utils

extension DiscordTextChannel {
	public func send(image: Image) throws {
		send(try DiscordMessage(fromImage: image))
	}
}

extension DiscordMessageLikeInitializable {
	public init(fromImage image: Image) throws {
		self.init(content: "", embed: nil, files: [
			DiscordFileUpload(data: try image.pngEncoded(), filename: "image.png", mimeType: "image/png")
		], tts: false)
	}
}
