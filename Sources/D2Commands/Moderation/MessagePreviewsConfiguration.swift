import D2MessageIO

public struct MessagePreviewsConfiguration: Sendable, Codable {
    public var enabledGuildIds: Set<GuildID> = []

    public init() {}
}
