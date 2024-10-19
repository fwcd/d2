import D2Commands
import D2MessageIO

/// Anything that handles interactions from Discord.
@CommandActor
public protocol InteractionHandler {
    mutating func handle(interaction: Interaction, sink: any Sink) async -> Bool
}

extension InteractionHandler {
    mutating func handle(interaction: Interaction, sink: any Sink) -> Bool { false }
}
