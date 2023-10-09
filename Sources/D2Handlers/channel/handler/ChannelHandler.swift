import D2MessageIO

/// Anything that handles channel updates from Discord.
public protocol ChannelHandler {
    mutating func handle(channelCreate channel: Channel, client: any MessageIOSink)

    mutating func handle(channelUpdate channel: Channel, client: any MessageIOSink)

    mutating func handle(channelDelete channel: Channel, client: any MessageIOSink)

    mutating func handle(threadCreate thread: Channel, client: any MessageIOSink)

    mutating func handle(threadUpdate thread: Channel, client: any MessageIOSink)

    mutating func handle(threadDelete thread: Channel, client: any MessageIOSink)
}

public extension ChannelHandler {
    func handle(channelCreate channel: Channel, client: any MessageIOSink) {}

    func handle(channelUpdate channel: Channel, client: any MessageIOSink) {}

    func handle(channelDelete channel: Channel, client: any MessageIOSink) {}

    func handle(threadCreate thread: Channel, client: any MessageIOSink) {}

    func handle(threadUpdate thread: Channel, client: any MessageIOSink) {}

    func handle(threadDelete thread: Channel, client: any MessageIOSink) {}
}

