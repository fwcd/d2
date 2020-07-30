import D2Utils
import D2MessageIO
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging

fileprivate let log = Logger(label: "D2Commands.MessageIOOutput")
fileprivate let contentLimit = 2000

public class MessageIOOutput: CommandOutput {
	private var context: CommandContext
	private let messageWriter = MessageWriter()
	private let onSent: ((Result<Message?, Error>) -> Void)?

	public let messageLengthLimit: Int? = 1800

	public init(context: CommandContext, onSent: ((Result<Message?, Error>) -> Void)? = nil) {
		self.context = context
		self.onSent = onSent
	}

	public func append(_ value: RichValue, to channel: OutputChannel) {
		guard let client = context.client else {
			log.warning("Cannot append to MessageIO without a client!")
			return
		}

		if case let .error(error, errorText: errorText) = value {
			log.warning("\(error.map { "\($0): " } ?? "")\(errorText)")
		}

		messageWriter.write(value: value).listen {
            var messages: [Message]
            do {
                messages = self.splitUp(message: try $0.get())
            } catch {
                log.error("Error while encoding message: \(error)")
                messages = [Message(content: """
                    An error occurred while encoding the message:
                    ```
                    \(error)
                    ```
                    """)]
            }

            sequence(promises: messages.map { m in { self.send(message: m, with: client, to: channel) } })
        }
	}

	private func send(message: Message, with client: MessageClient, to channel: OutputChannel) -> Promise<Void, Error> {
		Promise { then in
			switch channel {
				case .guildChannel(let id):
					client.sendMessage(message, to: id).listen {
						self.onSent?($0)
						then(.success(()))
					}
				case .dmChannel(let id):
					client.createDM(with: id).listenOrLogError { channelId in
						guard let id = channelId else {
							log.error("Could not send direct message, since no channel ID could be fetched")
							then(.success(()))
							return
						}
						client.sendMessage(message, to: id).listen {
							self.onSent?($0)
							then(.success(()))
						}
					}
				case .defaultChannel:
					if let textChannelId = self.context.channel?.id {
						client.sendMessage(message, to: textChannelId).listen {
							self.onSent?($0)
							then(.success(()))
						}
					} else {
						log.warning("No default text channel available")
						then(.success(()))
					}
			}
		}
	}

	private func splitUp(message: Message) -> [Message] {
		var remaining = message
		var results = [Message]()

		while remaining.content.count > contentLimit {
			results.append(Message(content: String(remaining.content.prefix(contentLimit))))
			remaining.content.removeFirst(contentLimit)
		}

		while remaining.embeds.count > 1, let embed = remaining.embeds.first {
			results.append(Message(embed: embed))
			remaining.embeds.removeFirst()
		}

		results.append(remaining)
		return results
	}

	public func update(context: CommandContext) {
		self.context = context
	}
}
