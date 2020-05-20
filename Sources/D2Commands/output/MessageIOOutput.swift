import D2MessageIO
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging

fileprivate let log = Logger(label: "D2Commands.MessageIOOutput")

public class MessageIOOutput: CommandOutput {
	private var context: CommandContext
	private let messageWriter = MessageWriter()
	private let onSent: ((Message?, HTTPURLResponse?) -> Void)?

	public let messageLengthLimit: Int? = 1800
	
	public init(context: CommandContext, onSent: ((Message?, HTTPURLResponse?) -> Void)? = nil) {
		self.context = context
		self.onSent = onSent
	}
	
	public func append(_ value: RichValue, to channel: OutputChannel) {
		guard let client = context.client else {
			log.warning("Cannot append to MessageIO without a client!")
			return
		}

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
			case .guildChannel(let id):
				client.sendMessage(message, to: id)
			case .dmChannel(let id):
				client.createDM(with: id) { channelId, _ in
					guard let id = channelId else {
						log.error("Could not send direct message, since no channel ID could be fetched")
						return
					}
					client.sendMessage(message, to: id, then: self.onSent)
				}
			case .defaultChannel:
				if let textChannelId = context.channel?.id {
					client.sendMessage(message, to: textChannelId, then: onSent)
				} else {
					log.warning("No default text channel available")
				}
		}
	}

	public func update(context: CommandContext) {
		self.context = context
	}
}
