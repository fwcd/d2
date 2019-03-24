import SwiftDiscord

protocol CommandOutput {
	func append(_ message: DiscordMessage)
}

extension CommandOutput {
	func append(_ str: String) {
		append(DiscordMessage(content: str))
	}
	
	func append(_ embed: DiscordEmbed) {
		append(DiscordMessage(content: "", embed: embed))
	}
}
