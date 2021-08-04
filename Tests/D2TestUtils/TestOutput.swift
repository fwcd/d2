import Foundation
import Utils
import D2MessageIO
@testable import D2Commands

/// An implementation of CommandOutput and MessageClient
/// that writes all messages into an array.
public class TestOutput {
    private var internalMessages = [Message]() {
        didSet {
            changed = true
        }
    }
    public var guilds: [Guild]? = []

    /// Whether the output changed since the last read.
    public private(set) var changed = false
    public var messages: [Message] {
        changed = false
        return internalMessages
    }
    public var contents: [String] { return messages.map { $0.content } }
    public var last: Message? { return messages.last }
    public var lastContent: String? { return last?.content }
    public var lastEmbedDescription: String? { return last?.embeds.first?.description }

    private let messageWriter = MessageWriter()

    public init() {}

    public func nthLast(_ n: Int = 1) -> Message? {
        messages[safely: messages.count - n]
    }

    public func nthLastContent(_ n: Int = 1) -> String? {
        nthLast(n)?.content
    }

    private func append(message: Message) {
        internalMessages.append(message)
    }
}

extension TestOutput: CommandOutput {
    public func append(_ value: RichValue, to channel: OutputChannel) {
        messageWriter.write(value: value).listen { [self] in
            internalMessages.append(try! $0.get())
        }
    }

    public func update(context: CommandContext) {
        // Ignore
    }
}

extension TestOutput: DefaultMessageClient {
    public var name: String { "Test" }

    public func guild(for guildId: GuildID) -> Guild? {
        guilds?.first { $0.id == guildId }
    }

    public func guildForChannel(_ channelId: ChannelID) -> Guild? {
        guilds?.first { $0.channels.keys.contains(channelId) }
    }

    public func sendMessage(_ message: D2MessageIO.Message, to channelId: ChannelID) -> Promise<D2MessageIO.Message?, Error> {
        append(message: message)
        return Promise(.success(message))
    }
}
