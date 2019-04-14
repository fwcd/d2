import SwiftDiscord
import D2Utils

extension DiscordTextChannel {
	public func send(image: Image) throws {
		send(try DiscordMessage(fromImage: image))
	}
}

extension DiscordMessageLikeInitializable {
	public init(fromImage image: Image, name: String? = nil) throws {
		self.init(content: "", embed: nil, files: [
			DiscordFileUpload(data: try image.pngEncoded(), filename: name ?? "image.png", mimeType: "image/png")
		], tts: false)
	}
}
