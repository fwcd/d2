import D2Commands
import D2MessageIO
import Logging

fileprivate let log = Logger(label: "D2Handlers.MessageDatabaseReactionHandler")

public struct MessageDatabaseReactionHandler: ReactionHandler {
    private let messageDB: MessageDatabase

    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }

    public func handle(createdReaction emoji: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any MessageIOSink) {
        do {
            if try messageDB.isTracked(channelId: channelId) {
                try messageDB.add(reaction: emoji, to: messageId, by: userId)
                log.debug("Wrote reaction '\(emoji.name)' to database")
            }
        } catch {
            log.warning("Could not insert reaction into DB: \(error)")
        }
    }

    public func handle(deletedReaction emoji: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any MessageIOSink) {
        do {
            if try messageDB.isTracked(channelId: channelId) {
                try messageDB.remove(reaction: emoji, from: messageId, by: userId)
                log.info("Removed reaction '\(emoji.name)' from database")
            }
        } catch {
            log.warning("Could not remove reaction from DB: \(error)")
        }
    }

    public func handle(deletedAllReactionsFrom messageId: MessageID, on channelId: ChannelID, client: any MessageIOSink) {
        do {
            if try messageDB.isTracked(channelId: channelId) {
                try messageDB.remove(allReactionsFrom: messageId)
                log.info("Removed all reactions from message id '\(messageId)' from database")
            }
        } catch {
            log.warning("Could not remove reactions from DB: \(error)")
        }
    }
}
