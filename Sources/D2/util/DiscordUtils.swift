import SwiftDiscord

extension DiscordTextChannel {
	func send(_ message: String) {
		send(DiscordMessage(content: message))
	}
}
