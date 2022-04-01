import Utils

/// A wrapper around a channel ID holding a
/// client reference.
public struct InteractiveTextChannel {
    public let id: ChannelID
    private let client: any MessageClient

    public init(id: ChannelID, client: any MessageClient) {
        self.id = id
        self.client = client
    }

    @discardableResult
    public func send(_ message: Message) -> Promise<Message?, Error> {
        client.sendMessage(message, to: id)
    }

    @discardableResult
    public func triggerTyping() -> Promise<Bool, Error> {
        client.triggerTyping(on: id)
    }
}
