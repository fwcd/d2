import SwiftDiscord

public class DiscordOutput: CommandOutput {
	private let client: DiscordEndpointConsumer
	private let defaultTextChannel: DiscordTextChannel?
	
	public init(client: DiscordEndpointConsumer, defaultTextChannel: DiscordTextChannel?) {
		self.client = client
		self.defaultTextChannel = defaultTextChannel
	}
	
	public func append(_ message: DiscordMessage, to channel: OutputChannel) {
		switch channel {
			case .serverChannel(let id):
				client.getChannel(id) { ch, _ in
					if let textChannel = ch.flatMap({ $0 as? DiscordTextChannel }) {
						textChannel.send(message)
					} else {
						print("Could not fetch server channel with ID \(id)")
					}
				}
			case .userChannel(let id):
				client.createDM(with: id) { ch, _ in
					if let textChannel = ch {
						textChannel.send(message)
					} else {
						print("Could not fetch user channel with ID \(id)")
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
