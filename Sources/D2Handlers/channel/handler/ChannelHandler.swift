import D2MessageIO

/// Anything that handles channel updates from Discord.
public protocol ChannelHandler {
    mutating func handle(channelCreate channel: Channel, client: MessageClient)

    mutating func handle(channelUpdate channel: Channel, client: MessageClient)

    mutating func handle(channelDelete channel: Channel, client: MessageClient)

    mutating func handle(threadCreate thread: Channel, client: MessageClient)

    mutating func handle(threadUpdate thread: Channel, client: MessageClient)

    mutating func handle(threadDelete thread: Channel, client: MessageClient)
}

extension ChannelHandler {
    func handle(channelCreate channel: Channel, client: MessageClient) {}

    func handle(channelUpdate channel: Channel, client: MessageClient) {}

    func handle(channelDelete channel: Channel, client: MessageClient) {}

    func handle(threadCreate thread: Channel, client: MessageClient) {}

    func handle(threadUpdate thread: Channel, client: MessageClient) {}

    func handle(threadDelete thread: Channel, client: MessageClient) {}
}

