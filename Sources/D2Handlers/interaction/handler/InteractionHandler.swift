import D2MessageIO

/// Anything that handles interactions from Discord.
public protocol InteractionHandler {
    mutating func handle(interaction: Interaction, client: any MessageIOSink) -> Bool
}

extension InteractionHandler {
    func handle(interaction: Interaction, client: any MessageIOSink) -> Bool { false }
}
