import D2MessageIO

/// Represents anything that modifies an (incoming) message.
public protocol MessageRewriter {
    func rewrite(message: Message, from client: any Sink) -> Message?
}
