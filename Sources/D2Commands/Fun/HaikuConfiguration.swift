import D2MessageIO

// TODO: Temporary solution until a more unified channel/guild
//       management system is in place, that also configures things
//       like message previews, ...

public struct HaikuConfiguration: Sendable, Codable {
    public var enabledChannelIds: Set<ChannelID> = []

    public init() {}
}
