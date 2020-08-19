import D2MessageIO

public struct MessagePreviewsConfiguration: Codable {
    public var enabledGuildIds: Set<GuildID> = []

    public init() {}
}
