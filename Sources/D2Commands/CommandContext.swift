import D2MessageIO
import Foundation
import Logging
import NIO

fileprivate let log = Logger(label: "D2Commands.CommandContext")

public struct CommandContext: Sendable {
    public let sink: (any Sink)?
    public let registry: CommandRegistry
    public let message: Message
    public let channel: InteractiveTextChannel?
    public let commandPrefix: String
    public let hostInfo: HostInfo?
    public let subscriptions: SubscriptionSet

    /// The global event loop group.
    public let eventLoopGroup: (any EventLoopGroup)?

    public var author: User? { message.author }
    public var timestamp: Date? { message.timestamp }
    public var guildMember: Guild.Member? { message.guildMember }
    public var guild: Guild? {
        get async {
            await message.channelId.asyncFlatMap { await sink?.guildForChannel($0) }
        }
    }

    @CommandActor
    public var isSubscribed: Bool { (channel?.id).map { subscriptions.contains($0) } ?? false }

    public init(
        sink: (any Sink)?,
        registry: CommandRegistry,
        message: Message,
        commandPrefix: String,
        hostInfo: HostInfo? = nil,
        subscriptions: SubscriptionSet,
        eventLoopGroup: (any EventLoopGroup)? = nil
    ) {
        self.sink = sink
        self.registry = registry
        self.message = message
        self.commandPrefix = commandPrefix
        self.hostInfo = hostInfo
        self.subscriptions = subscriptions
        self.eventLoopGroup = eventLoopGroup

        channel = sink.flatMap { c in message.channelId.map { InteractiveTextChannel(id: $0, sink: c) } }
    }

    /// Subscribes to the current channel.
    public func subscribeToChannel() {
        if let id = channel?.id {
            subscriptions.subscribe(to: id)
        } else {
            log.warning("Tried to subscribe to current channel without a channel being present.")
        }
    }

    /// Unsubscribes from the current channel.
    public func unsubscribeFromChannel() {
        if let id = channel?.id {
            subscriptions.unsubscribe(from: id)
        } else {
            log.warning("Tried to unsubscribe from current channel without a channel being present.")
        }
    }
}
