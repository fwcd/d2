import D2MessageIO
import Logging

fileprivate let log = Logger(label: "D2Commands.CommandContext")

public struct CommandContext {
    public let client: MessageClient?
    public let registry: CommandRegistry
    public let message: Message
    public let channel: InteractiveTextChannel?
    public let commandPrefix: String
    public let subscriptions: SubscriptionSet

    public var author: User? { return message.author }
    public var guildMember: Guild.Member? { return message.guildMember }
    public var guild: Guild? { return message.channelId.flatMap { client?.guildForChannel($0) } }

    public var isSubscribed: Bool { return (channel?.id).map { subscriptions.contains($0) } ?? false }

    public init(
        client: MessageClient?,
        registry: CommandRegistry,
        message: Message,
        commandPrefix: String,
        subscriptions: SubscriptionSet
    ) {
        self.client = client
        self.registry = registry
        self.message = message
        self.commandPrefix = commandPrefix
        self.subscriptions = subscriptions

        channel = client.flatMap { c in message.channelId.map { InteractiveTextChannel(id: $0, client: c) } }
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
