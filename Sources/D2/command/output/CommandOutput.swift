import SwiftDiscord
import D2Utils

protocol CommandOutput {
	func append(_ message: DiscordMessage)
}

extension CommandOutput {
	func append(_ str: String) {
		append(DiscordMessage(content: str))
	}
	
	func append(_ embed: DiscordEmbed) {
		append(DiscordMessage(fromEmbed: embed))
	}
	
	func append(_ image: Image) throws {
		append(try DiscordMessage(fromImage: image))
	}
}
