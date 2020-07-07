import D2MessageIO

/**
 * Anything that handles incoming reactions
 * to messages from Discord.
 */
public protocol ReactionHandler {
    mutating func handle(reaction emoji: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: MessageClient)
}
