import D2Commands
import D2MessageIO
import Logging

fileprivate let log = Logger(label: "D2Handlers.MessageDatabaseChannelHandler")

public struct MessageDatabaseChannelHandler: ChannelHandler {
    private let messageDB: MessageDatabase

    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }

    private func update(channel: Channel, on eventName: String, sink: any Sink) {
        do {
            if let guild = sink.guildForChannel(channel.id) {
                log.info("Updating channel '\(channel.name)' on \(eventName) into message database...")
                try messageDB.insert(channel: channel, on: guild)
            }
        } catch {
            log.warning("Could not update channel on \(eventName) into message database: \(error)")
        }
    }

    public func handle(channelCreate channel: Channel, sink: any Sink) {
        update(channel: channel, on: "creation", sink: sink)
    }

    public func handle(channelUpdate channel: Channel, sink: any Sink) {
        update(channel: channel, on: "update", sink: sink)
    }

    public func handle(threadCreate thread: Channel, sink: any Sink) {
        update(channel: thread, on: "thread creation", sink: sink)
    }

    public func handle(threadUpdate thread: Channel, sink: any Sink) {
        update(channel: thread, on: "thread update", sink: sink)
    }
}
