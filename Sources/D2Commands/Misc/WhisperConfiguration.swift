import D2MessageIO

public struct WhisperConfiguration: Sendable, Codable {
    public var enabledChannelIds: Set<ChannelID> = []

    public init() {}
}
