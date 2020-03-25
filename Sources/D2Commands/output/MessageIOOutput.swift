import D2MessageIO
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging

fileprivate let log = Logger(label: "D2Commands.MessageIOOutput")

public class MessageIOOutput: CommandOutput {
	private let messageWriter = MessageWriter()
	private let client: MessageClient
	private let defaultTextChannelId: ChannelID?
	public let messageLengthLimit: Int? = 1800
	private let onSent: ((Message?, HTTPURLResponse?) -> Void)?
	
	public init(client: MessageClient, defaultTextChannelId: ChannelID?, onSent: ((Message?, HTTPURLResponse?) -> Void)? = nil) {
		self.client = client
		self.defaultTextChannelId = defaultTextChannelId
		self.onSent = onSent
	}
	
	public func append(_ value: RichValue, to channel: OutputChannel) {
		var message: Message
		do {
			if case let .error(error, errorText: errorText) = value {
				log.warning("\(error.map { "\($0): " } ?? "")\(errorText)")
			}
			message = try messageWriter.write(value: value)
		} catch {
			log.error("Error while encoding message: \(error)")
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
				client.createDM(with: id) { channelId, _ in
					guard let id = channelId else {
						log.error("Could not send direct message, since no channel ID could be fetched")
						return
					}
					self.client.sendMessage(message, to: id, then: self.onSent)
				}
			case .defaultChannel:
				if let textChannelId = defaultTextChannelId {
					client.sendMessage(message, to: textChannelId, then: onSent)
				} else {
					log.warning("No default text channel available")
				}
		}
	}
}
