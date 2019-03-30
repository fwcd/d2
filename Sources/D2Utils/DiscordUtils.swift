import SwiftDiscord

extension DiscordTextChannel {
	public func send(_ message: String) {
		send(DiscordMessage(content: message))
	}
	
	public func send(embed: DiscordEmbed) {
		send(DiscordMessage(fromEmbed: embed))
	}
}

extension DiscordMessage {
	public init(fromEmbed embed: DiscordEmbed) {
		self.init(content: "", embed: embed)
	}
}
