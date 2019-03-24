import SwiftDiscord

class DiscordChannelOutput: CommandOutput {
	private let channel: DiscordTextChannel?
	
	init(channel: DiscordTextChannel?) {
		self.channel = channel
	}
	
	func append(_ message: DiscordMessage) {
		channel?.send(message)
	}
}
