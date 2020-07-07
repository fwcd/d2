import D2Commands
import D2MessageIO

public struct MessageDatabaseReactionHandler: ReactionHandler {
    private let messageDB: MessageDatabase

    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }

    public func handle(reaction emoji: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: MessageClient) {
        // TODO
    }
}
