import D2MessageIO
import D2Commands
import Logging

fileprivate let log = Logger(label: "D2Handlers.MessageDatabaseHandler")

public struct MessageDatabaseHandler: MessageHandler {
    private let messageDB: MessageDatabase
    
    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }

    public func handle(message: Message, from client: MessageClient) -> Bool {
        if let channelId = message.channelId,
                let guildId = message.guild?.id,
                client.permissionsForUser(guildId, in: channelId, on: guildId).contains(.readMessages) {
            do {
                try messageDB.insertMessage(message: message)
                try messageDB.generateMarkovTransitions(for: message)
                log.info("Wrote message '\(message.content.truncate(10, appending: "..."))' to database")
            } catch {
                log.warning("Could not insert message into DB: \(error)")
            }
        }
        return false
    }
}
