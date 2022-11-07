import D2Commands
import D2MessageIO
import NIO

public struct SubscriptionReactionHandler: ReactionHandler {
    private let commandPrefix: String
    private let registry: CommandRegistry
    private let manager: SubscriptionManager
    private let utilityEventLoopGroup: EventLoopGroup

    public init(commandPrefix: String, registry: CommandRegistry, manager: SubscriptionManager, utilityEventLoopGroup: EventLoopGroup) {
        self.commandPrefix = commandPrefix
        self.registry = registry
        self.manager = manager
        self.utilityEventLoopGroup = utilityEventLoopGroup
    }

    public func handle(createdReaction emoji: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any MessageClient) {
        guard
            let guild = client.guildForChannel(channelId),
            let member = guild.members[userId] else { return }
        // TODO: Query the actual message that the user reacted to here
        let message = Message(content: "Dummy", channelId: channelId, id: messageId)
        let user = member.user
        manager.notifySubscriptions(on: channelId, isBot: user.bot) {
            let context = CommandContext(
                client: client,
                registry: registry,
                message: message,
                commandPrefix: commandPrefix,
                subscriptions: $1,
                utilityEventLoopGroup: utilityEventLoopGroup
            )
            registry[$0]?.onSubscriptionReaction(emoji: emoji, by: user, output: MessageIOOutput(context: context), context: context)
        }
    }
}
