import D2Commands
import D2MessageIO

/// Anything that handles channel updates from Discord.
@CommandActor
public protocol ChannelHandler {
    mutating func handle(channelCreate channel: Channel, sink: any Sink) async

    mutating func handle(channelUpdate channel: Channel, sink: any Sink) async

    mutating func handle(channelDelete channel: Channel, sink: any Sink) async

    mutating func handle(threadCreate thread: Channel, sink: any Sink) async

    mutating func handle(threadUpdate thread: Channel, sink: any Sink) async

    mutating func handle(threadDelete thread: Channel, sink: any Sink) async
}

public extension ChannelHandler {
    mutating func handle(channelCreate channel: Channel, sink: any Sink) {}

    mutating func handle(channelUpdate channel: Channel, sink: any Sink) {}

    mutating func handle(channelDelete channel: Channel, sink: any Sink) {}

    mutating func handle(threadCreate thread: Channel, sink: any Sink) {}

    mutating func handle(threadUpdate thread: Channel, sink: any Sink) {}

    mutating func handle(threadDelete thread: Channel, sink: any Sink) {}
}

