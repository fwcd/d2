import D2MessageIO

/// Anything that handles channel updates from Discord.
public protocol ChannelHandler {
    mutating func handle(channelCreate channel: Channel, client: any MessageClient)

    mutating func handle(channelUpdate channel: Channel, client: any MessageClient)

    mutating func handle(channelDelete channel: Channel, client: any MessageClient)

    mutating func handle(threadCreate thread: Channel, client: any MessageClient)

    mutating func handle(threadUpdate thread: Channel, client: any MessageClient)

    mutating func handle(threadDelete thread: Channel, client: any MessageClient)
}

public extension ChannelHandler {
    func handle(channelCreate channel: Channel, client: any MessageClient) {}

    func handle(channelUpdate channel: Channel, client: any MessageClient) {}

    func handle(channelDelete channel: Channel, client: any MessageClient) {}

    func handle(threadCreate thread: Channel, client: any MessageClient) {}

    func handle(threadUpdate thread: Channel, client: any MessageClient) {}

    func handle(threadDelete thread: Channel, client: any MessageClient) {}
}

