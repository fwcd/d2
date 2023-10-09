import D2MessageIO

/// Anything that handles incoming reactions
/// to messages from Discord.
public protocol ReactionHandler {
    mutating func handle(createdReaction emoji: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any MessageIOSink)

    mutating func handle(deletedReaction emoji: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any MessageIOSink)

    mutating func handle(deletedAllReactionsFrom messageId: MessageID, on channelId: ChannelID, client: any MessageIOSink)
}

public extension ReactionHandler {
    func handle(createdReaction emoji: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any MessageIOSink) {}

    func handle(deletedReaction emoji: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any MessageIOSink) {}

    func handle(deletedAllReactionsFrom messageId: MessageID, on channelId: ChannelID, client: any MessageIOSink) {}
}
