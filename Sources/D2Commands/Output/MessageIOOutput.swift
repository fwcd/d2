import Utils
import D2MessageIO
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging

private let log = Logger(label: "D2Commands.MessageIOOutput")
private let contentLimit = 2000
private let maxSplitFragments = 4

public class MessageIOOutput: CommandOutput {
    private var context: CommandContext
    private let messageWriter: MessageWriter
    private let onSent: (([Message]) async -> Void)?

    public init(context: CommandContext, onSent: (([Message]) async -> Void)? = nil) {
        self.context = context
        self.onSent = onSent

        messageWriter = MessageWriter(context: context)
    }

    public func append(_ value: RichValue, to channel: OutputChannel) async {
        guard let sink = context.sink else {
            log.warning("Cannot append to MessageIO without a client!")
            return
        }

        if case let .error(error, errorText: errorText) = value {
            log.warning("\(error.map { "\($0): " } ?? "")\(errorText)")
        }

        var messages: [Message]
        do {
            let baseMessage = try await messageWriter.write(value: value)
            messages = self.splitUp(message: baseMessage)
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

        await withTaskGroup(of: Message?.self) { group in
            for message in messages {
                group.addTask {
                    do {
                        return try await self.send(message: message, with: sink, to: channel)
                    } catch {
                        log.error("Could not send \(message) to \(channel): \(error)")
                        return nil
                    }
                }
            }

            var sentMessages: [Message] = []
            for await sentMessage in group {
                if let sentMessage {
                    sentMessages.append(sentMessage)
                }
            }

            await onSent?(sentMessages)
        }
    }

    private func send(message: Message, with sink: any Sink, to channel: OutputChannel) async throws -> Message? {
        switch channel {
            case .guildChannel(let id):
                return try await sink.sendMessage(message, to: id)
            case .dmChannel(let id):
                let channelId = try await sink.createDM(with: id)
                guard let id = channelId else {
                    throw MessageIOOutputError.couldNotSendDM
                }
                return try await sink.sendMessage(message, to: id)
            case .defaultChannel:
                if let textChannelId = self.context.channel?.id {
                    return try await sink.sendMessage(message, to: textChannelId)
                } else {
                    throw MessageIOOutputError.noDefaultChannelAvailable
                }
        }
    }

    private func splitUp(message: Message) -> [Message] {
        var remaining = message
        var results = [Message]()

        if remaining.content.count > contentLimit {
            if let data = remaining.content.data(using: .utf8) {
                remaining.content = ""
                remaining.files.append(Message.FileUpload(
                    data: data,
                    filename: "output.txt",
                    mimeType: "text/plain"
                ))
            } else {
                log.warning("Message content could not be UTF-8-encoded, this is probably not good. Truncating it to the content limit and letting the lower levels deal with it...")
                remaining.content = String(remaining.content.prefix(contentLimit))
            }
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
