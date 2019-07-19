import D2MessageIO
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// TODO: Rename to MessageIOOutput
public class DiscordOutput: CommandOutput {
	private let messageWriter = DiscordMessageWriter()
	private let client: MessageClient
	private let defaultTextChannel: TextChannel?
	public let messageLengthLimit: Int? = 1800
	private let onSent: ((Message?, HTTPURLResponse?) -> Void)?
	
	public init(client: MessageClient, defaultTextChannel: TextChannel?, onSent: ((Message?, HTTPURLResponse?) -> Void)? = nil) {
		self.client = client
		self.defaultTextChannel = defaultTextChannel
		self.onSent = onSent
	}
	
	public func append(_ value: RichValue, to channel: OutputChannel) {
		var message: Message
		do {
			message = try messageWriter.write(value: value)
		} catch {
			print("Error while encoding message:")
			print(error)
			message = Message(content: """
				An error occurred while encoding the message:
				```
				\(error)
				```
				""")
		}
		switch channel {
			case .serverChannel(let id): client.sendMessage(message, to: id)
			case .userChannel(let id):
				client.createDM(with: id) { ch, _ in
					if let channelId = ch.map({ $0.id }) {
						self.client.sendMessage(message, to: channelId, callback: self.onSent)
					} else {
						print("Could not find user channel \(id)")
					}
				}
			case .defaultChannel:
				if let textChannel = defaultTextChannel {
					client.sendMessage(message, to: textChannel.id, callback: onSent)
				} else {
					print("No default text channel available")
				}
		}
	}
}
