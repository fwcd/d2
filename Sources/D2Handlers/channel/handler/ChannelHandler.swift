import D2MessageIO

/// Anything that handles channel updates from Discord.
public protocol ChannelHandler {
    mutating func handle(channelCreate channel: Channel, client: any Sink)

    mutating func handle(channelUpdate channel: Channel, client: any Sink)

    mutating func handle(channelDelete channel: Channel, client: any Sink)

    mutating func handle(threadCreate thread: Channel, client: any Sink)

    mutating func handle(threadUpdate thread: Channel, client: any Sink)

    mutating func handle(threadDelete thread: Channel, client: any Sink)
}

public extension ChannelHandler {
    func handle(channelCreate channel: Channel, client: any Sink) {}

    func handle(channelUpdate channel: Channel, client: any Sink) {}

    func handle(channelDelete channel: Channel, client: any Sink) {}

    func handle(threadCreate thread: Channel, client: any Sink) {}

    func handle(threadUpdate thread: Channel, client: any Sink) {}

    func handle(threadDelete thread: Channel, client: any Sink) {}
}

