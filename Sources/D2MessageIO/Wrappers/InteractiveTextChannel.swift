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
    public func send(_ message: Message) async throws -> Message? {
        try await sink.sendMessage(message, to: id)
    }

    public func triggerTyping() async throws {
        try await sink.triggerTyping(on: id)
    }
}
