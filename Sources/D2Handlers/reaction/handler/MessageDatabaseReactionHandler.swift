import D2Commands
import D2MessageIO
import Logging

fileprivate let log = Logger(label: "D2Handlers.MessageDatabaseReactionHandler")

public struct MessageDatabaseReactionHandler: ReactionHandler {
    private let messageDB: MessageDatabase

    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }

    public func handle(reaction emoji: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: MessageClient) {
        do {
            if try messageDB.isTracked(channelId: channelId) {
                try messageDB.add(reaction: emoji, to: messageId)
                log.info("Wrote reaction '\(emoji.name)' to database")
            } else {
                log.info("Not inserting reaction from untracked guild into DB")
            }
        } catch {
            log.warning("Could not insert reaction into DB: \(error)")
        }
    }
}
