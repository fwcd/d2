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

    func handle(message: Message, from client: MessageClient) -> Bool {
        guard !manager.isEmpty, let channelId = message.channelId else { return false }

		let output = MessageIOOutput(client: client, defaultTextChannelId: channelId)
		let context = CommandContext(
			client: client,
			registry: registry,
			message: message
		)
		let isBot = message.author?.bot ?? false
	
        manager.notifySubscriptions(on: channelId, isBot: isBot) {
            $0.command.onSubscriptionMessage(withContent: message.content, output: output, context: context)
        }
        
        return true
    }
}
