import Utils

/// A wrapper around a channel ID holding a
/// client reference.
public struct InteractiveTextChannel {
    public let id: ChannelID
    private let sink: any Sink

    public init(id: ChannelID, sink: any Sink) {
        self.id = id
        self.sink = sink
    }

    @discardableResult
    public func send(_ message: Message) -> Promise<Message?, any Error> {
        sink.sendMessage(message, to: id)
    }

    @discardableResult
    public func triggerTyping() -> Promise<Bool, any Error> {
        sink.triggerTyping(on: id)
    }
}
