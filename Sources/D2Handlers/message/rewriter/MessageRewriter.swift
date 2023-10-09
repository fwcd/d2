import D2MessageIO

/// Represents anything that modifies an (incoming) message.
public protocol MessageRewriter {
    func rewrite(message: Message, sink: any Sink) -> Message?
}
