import SwiftDiscord

public class DiscordOutput: CommandOutput {
	private let client: DiscordClient
	private let defaultTextChannel: DiscordTextChannel?
	
	public init(client: DiscordClient, defaultTextChannel: DiscordTextChannel?) {
		self.client = client
		self.defaultTextChannel = defaultTextChannel
	}
	
	public func append(_ message: DiscordMessage, to channel: OutputChannel) {
		switch channel {
			case .serverChannel(let id): client.sendMessage(message, to: id)
			case .userChannel(let id):
				client.createDM(with: id) { ch, _ in
					if let channelId = ch.map({ $0.id }) {
						self.client.sendMessage(message, to: channelId)
					} else {
						print("Could not find user channel \(id)")
					}
				}
			case .defaultChannel:
				if let textChannel = defaultTextChannel {
					textChannel.send(message)
				} else {
					print("No default text channel available")
				}
		}
	}
}
