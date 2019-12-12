import D2MessageIO
import D2Commands

/** Handles messages from command subscriptions. */
struct SubscriptionHandler: MessageHandler {
    private let registry: CommandRegistry
    private let manager: SubscriptionManager
    
    init(registry: CommandRegistry, manager: SubscriptionManager) {
        self.registry = registry
        self.manager = manager
    }

    func handle(message: Message, from client: DiscordClient) -> Bool {
        guard !manager.isEmpty else { return false }

		let output = DiscordOutput(client: client, defaultTextChannel: message.channel)
		let context = CommandContext(
			guild: client.guildForChannel(message.channelId),
			registry: registry,
			message: message
		)
		let isBot = message.author.bot
	
        manager.notifySubscriptions(on: message.channelId, isBot: isBot) {
            $0.command.onSubscriptionMessage(withContent: message.content, output: output, context: context)
        }
        
        return true
    }
}
