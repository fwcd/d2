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

extension Int: DiscordEncodable {
	public var discordStringEncoded: String { return String(self) }
}

extension Double: DiscordEncodable {
	public var discordStringEncoded: String { return String(self) }
}

extension String: DiscordEncodable {
	public var discordStringEncoded: String { return self }
}
