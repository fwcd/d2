import SwiftDiscord
import D2Utils

extension DiscordTextChannel {
	public func send(image: Image) throws {
		send(try DiscordMessage(fromImage: image))
	}
	
	public func send(gif: AnimatedGif) throws {
		send(try DiscordMessage(fromGif: gif))
	}
}

extension DiscordMessageLikeInitializable {
	public init(fromImage image: Image, name: String? = nil) throws {
		self.init(content: "", embed: nil, files: [
			DiscordFileUpload(data: try image.pngEncoded(), filename: name ?? "image.png", mimeType: "image/png")
		], tts: false)
	}
	
	public init(fromGif gif: AnimatedGif, name: String? = nil) {
		self.init(content: "", embed: nil, files: [
			DiscordFileUpload(data: gif.data, filename: name ?? "image.gif", mimeType: "image/gif")
		], tts: false)
	}
}
