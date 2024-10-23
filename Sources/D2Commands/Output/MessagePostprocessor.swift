import D2MessageIO

/// A facility that modifies an outgoing message. Analogous to
/// `MessageRewriter`, which processes incoming messages.
@CommandActor
protocol MessagePostprocessor {
    func postprocess(message: Message, context: CommandContext) async throws -> Message
}
