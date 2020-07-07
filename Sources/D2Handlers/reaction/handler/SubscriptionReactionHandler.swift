import D2Commands
import D2MessageIO

public struct SubscriptionReactionHandler: ReactionHandler {
    private let commandPrefix: String
    private let registry: CommandRegistry
    private let manager: SubscriptionManager
    
    public init(commandPrefix: String, registry: CommandRegistry, manager: SubscriptionManager) {
        self.commandPrefix = commandPrefix
        self.registry = registry
        self.manager = manager
    }

    public func handle(reaction emoji: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: MessageClient) {
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
				subscriptions: $1
			)
			registry[$0]?.onSubscriptionReaction(emoji: emoji, by: user, output: MessageIOOutput(context: context), context: context)
		}
    }
}
