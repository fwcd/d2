import D2MessageIO

public struct ThreadConfiguration: Sendable, Codable {
    /// Channels whose threads are considered for unarchivings.
    public var keepaliveParentChannelIds: Set<ChannelID> = []

    /// Permanently archived threads.
    public var permanentlyArchivedThreadIds: Set<ChannelID> = []

    public init() {}
}
