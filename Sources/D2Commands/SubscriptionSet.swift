import D2MessageIO

public class SubscriptionSet: Sequence {
    private var subscriptions: Set<ChannelID> = []
    public var count: Int { subscriptions.count }
    public var isEmpty: Bool { subscriptions.isEmpty }
    
    public init() {}
    
    public func subscribe(to channelId: ChannelID) {
        subscriptions.insert(channelId)
    }
    
    public func unsubscribe(from channelId: ChannelID) {
        subscriptions.remove(channelId)
    }
    
    public func contains(_ channelId: ChannelID) -> Bool {
        subscriptions.contains(channelId)
    }
    
    public func makeIterator() -> Set<ChannelID>.Iterator {
        subscriptions.makeIterator()
    }
}
