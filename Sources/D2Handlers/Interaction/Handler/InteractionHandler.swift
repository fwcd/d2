import D2MessageIO

/// Anything that handles interactions from Discord.
public protocol InteractionHandler {
    mutating func handle(interaction: Interaction, sink: any Sink) async -> Bool
}

extension InteractionHandler {
    func handle(interaction: Interaction, sink: any Sink) -> Bool { false }
}
