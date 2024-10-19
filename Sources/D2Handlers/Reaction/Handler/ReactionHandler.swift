import D2Commands
import D2MessageIO

/// Anything that handles incoming reactions
/// to messages from Discord.
@CommandActor
public protocol ReactionHandler {
    mutating func handle(createdReaction emoji: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink) async

    mutating func handle(deletedReaction emoji: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink) async

    mutating func handle(deletedAllReactionsFrom messageId: MessageID, on channelId: ChannelID, sink: any Sink) async
}

public extension ReactionHandler {
    func handle(createdReaction emoji: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink) async {}

    func handle(deletedReaction emoji: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink) async {}

    func handle(deletedAllReactionsFrom messageId: MessageID, on channelId: ChannelID, sink: any Sink) async {}
}
