import SwiftDiscord

extension DiscordTextChannel {
	func send(_ message: String) {
		send(DiscordMessage(content: message))
	}
	
	func send(embed: DiscordEmbed) {
		send(DiscordMessage(content: "", embed: embed))
	}
}
