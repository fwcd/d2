import D2Commands
import D2MessageIO
import NIO

public struct SubscriptionReactionHandler: ReactionHandler {
    private let commandPrefix: String
    private let registry: CommandRegistry
    private let manager: SubscriptionManager
    private let eventLoopGroup: any EventLoopGroup

    public init(commandPrefix: String, registry: CommandRegistry, manager: SubscriptionManager, eventLoopGroup: any EventLoopGroup) {
        self.commandPrefix = commandPrefix
        self.registry = registry
        self.manager = manager
        self.eventLoopGroup = eventLoopGroup
    }

    public func handle(createdReaction emoji: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink) async {
        guard
            let guild = await sink.guildForChannel(channelId),
            let member = guild.members[userId] else { return }
        // TODO: Query the actual message that the user reacted to here
        let message = Message(content: "Dummy", channelId: channelId, id: messageId)
        let user = member.user
        await manager.notifySubscriptions(on: channelId, isBot: user.bot) {
            let context = CommandContext(
                sink: sink,
                registry: registry,
                message: message,
                commandPrefix: commandPrefix,
                subscriptions: $1,
                eventLoopGroup: eventLoopGroup
            )
            await registry[$0]?.onSubscriptionReaction(emoji: emoji, by: user, output: MessageIOOutput(context: context), context: context)
        }
    }
}
