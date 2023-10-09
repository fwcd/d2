import D2MessageIO
import D2Commands
import Logging

fileprivate let log = Logger(label: "D2Handlers.MessageDatabaseHandler")

public struct MessageDatabaseHandler: MessageHandler {
    private let messageDB: MessageDatabase

    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }

    public func handle(message: Message, sink: any Sink) -> Bool {
        if !(message.author?.bot ?? true) {
            if let guildId = message.guild?.id {
                do {
                    if try messageDB.isTracked(guildId: guildId) {
                        try messageDB.insert(message: message)
                        try messageDB.generateMarkovTransitions(for: message)
                        log.debug("Wrote message '\(message.content.truncated(to: 10, appending: "..."))' to database")
                    } else {
                        log.debug("Not inserting message from untracked guild into DB")
                    }
                } catch {
                    log.warning("Could not insert message into DB: \(error)")
                }
            } else {
                log.debug("Not inserting DM into DB")
            }
        } else {
            log.debug("Not inserting bot message into DB")
        }

        return false
    }
}
