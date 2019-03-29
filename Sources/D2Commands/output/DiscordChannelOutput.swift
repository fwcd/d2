import SwiftDiscord

public class DiscordChannelOutput: CommandOutput {
	private let channel: DiscordTextChannel?
	
	public init(channel: DiscordTextChannel?) {
		self.channel = channel
	}
	
	public func append(_ message: DiscordMessage) {
		channel?.send(message)
	}
}
