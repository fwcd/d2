import D2Commands
import D2MessageIO

/// Represents anything that modifies an (incoming) message.
@CommandActor
public protocol MessageRewriter {
    func rewrite(message: Message, sink: any Sink) async -> Message?
}
