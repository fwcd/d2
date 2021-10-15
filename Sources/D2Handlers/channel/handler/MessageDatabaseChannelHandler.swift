import D2Commands
import D2MessageIO
import Logging

fileprivate let log = Logger(label: "D2Handlers.MessageDatabaseChannelHandler")

public struct MessageDatabaseChannelHandler: ChannelHandler {
    private let messageDB: MessageDatabase

    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }

    private func update(channel: Channel, on eventName: String, client: MessageClient) {
        do {
            if let guild = client.guildForChannel(channel.id) {
                log.info("Updating channel '\(channel.name)' on \(eventName) into message database...")
                try messageDB.insert(channel: channel, on: guild)
            }
        } catch {
            log.warning("Could not update channel on \(eventName) into message database: \(error)")
        }
    }

    public func handle(channelCreate channel: Channel, client: MessageClient) {
        update(channel: channel, on: "creation", client: client)
    }

    public func handle(channelUpdate channel: Channel, client: MessageClient) {
        update(channel: channel, on: "update", client: client)
    }

    public func handle(threadCreate thread: Channel, client: MessageClient) {
        update(channel: thread, on: "thread creation", client: client)
    }

    public func handle(threadUpdate thread: Channel, client: MessageClient) {
        update(channel: thread, on: "thread update", client: client)
    }
}
