import Utils
import D2MessageIO
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging

fileprivate let log = Logger(label: "D2Commands.MessageIOOutput")
fileprivate let contentLimit = 2000
fileprivate let maxSplitFragments = 4

public class MessageIOOutput: CommandOutput {
    private var context: CommandContext
    private let messageWriter = MessageWriter()
    private let onSent: (([Message]) -> Void)?

    public init(context: CommandContext, onSent: (([Message]) -> Void)? = nil) {
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

        messageWriter.write(value: value)
            .mapResult { (r: Result<Message, Error>) -> Result<[Message], Error> in
                var messages: [Message]
                do {
                    messages = self.splitUp(message: try r.get())
                    if messages.count > maxSplitFragments {
                        log.warning("Splitting up message resulted in \(messages.count) fragments, truncating to \(maxSplitFragments) messages...")
                        messages = Array(messages.prefix(5))
                    }
                } catch {
                    log.error("Error while encoding message: \(error)")
                    messages = [Message(content: """
                        An error occurred while encoding the message:
                        ```
                        \(error)
                        ```
                        """)]
                }
                return .success(messages)
            }
            .then { sequence(promises: $0.map { m in { self.send(message: m, with: client, to: channel) } }) }
            .map { $0.compactMap { $0 } }
            .listenOrLogError { self.onSent?($0) }
    }

    private func send(message: Message, with client: MessageClient, to channel: OutputChannel) -> Promise<Message?, Error> {
        switch channel {
            case .guildChannel(let id):
                return client.sendMessage(message, to: id)
            case .dmChannel(let id):
                return client.createDM(with: id)
                    .thenCatching { channelId in
                        guard let id = channelId else {
                            throw MessageIOOutputError.couldNotSendDM
                        }
                        return client.sendMessage(message, to: id)
                    }
            case .defaultChannel:
                if let textChannelId = self.context.channel?.id {
                    return client.sendMessage(message, to: textChannelId)
                } else {
                    return Promise(.failure(MessageIOOutputError.noDefaultChannelAvailable))
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
