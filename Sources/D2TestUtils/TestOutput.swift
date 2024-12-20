import Foundation
import Utils
import D2MessageIO
import D2Commands

/// An implementation of CommandOutput and Sink
/// that writes all messages into an array.
@CommandActor
public final class TestOutput {
    private var _messages = [Message]() {
        didSet {
            changed = true
        }
    }
    public var guilds: [Guild]? = []

    /// Whether the output changed since the last read.
    public private(set) var changed = false
    public var messages: [Message] {
        get {
            changed = false
            return _messages
        }
        set {
            changed = false
            _messages = newValue
        }
    }
    public var contents: [String] { return messages.map { $0.content } }
    public var last: Message? { return messages.last }
    public var lastContent: String? { return last?.content }
    public var lastReactions: [Message.Reaction] { return last?.reactions ?? [] }
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
        _messages.append(message)
    }

    public func modify(action: @CommandActor (TestOutput) throws -> Void) rethrows {
        try action(self)
    }
}

extension TestOutput: CommandOutput {
    public func append(_ value: RichValue, to channel: OutputChannel) async {
        let message = try! await messageWriter.write(value: value)
        _messages.append(message)
    }

    public func update(context: CommandContext) {
        // Ignore
    }
}

extension TestOutput: DefaultSink {
    public nonisolated var name: String { "Test" }

    public func guild(for guildId: GuildID) -> Guild? {
        guilds?.first { $0.id == guildId }
    }

    public func guildForChannel(_ channelId: ChannelID) -> Guild? {
        guilds?.first { $0.channels.keys.contains(channelId) }
    }

    public func sendMessage(_ message: D2MessageIO.Message, to channelId: ChannelID) -> D2MessageIO.Message? {
        append(message: message)
        return message
    }

    public func createReaction(for messageId: MessageID, on channelId: ChannelID, emoji: String) -> Message? {
        for i in messages.indices where messages[i].id == messageId {
            var reactions = Dictionary(grouping: messages[i].reactions, by: \.emoji.description)
            // TODO: Add proper conversion from emoji string to Emoji structure
            assert((reactions[emoji]?.count ?? 0) <= 1, "Reactions should be unique by emoji")
            var reaction = reactions[emoji]?.first ?? Message.Reaction(
                count: 0,
                me: true,
                emoji: .init(managed: false, animated: false, name: emoji, requireColons: false)
            )
            reaction.count += 1
            reactions[emoji] = [reaction]
            messages[i].reactions = reactions.values.flatMap { $0 }
            return .init(messages[i])
        }
        return nil
    }
}
