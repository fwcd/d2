import D2MessageIO

@CommandActor
public class SubscriptionSet {
    public private(set) var channelIds: Set<ChannelID> = []
    public var count: Int { channelIds.count }
    public var isEmpty: Bool { channelIds.isEmpty }

    public init() {}

    public func subscribe(to channelId: ChannelID) {
        channelIds.insert(channelId)
    }

    public func unsubscribe(from channelId: ChannelID) {
        channelIds.remove(channelId)
    }

    public func contains(_ channelId: ChannelID) -> Bool {
        channelIds.contains(channelId)
    }
}
