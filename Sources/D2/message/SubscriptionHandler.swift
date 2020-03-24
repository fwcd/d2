import D2MessageIO
import D2Commands

/** Handles messages from command subscriptions. */
struct SubscriptionHandler: MessageHandler {
    private let commandPrefix: String
    private let registry: CommandRegistry
    private let manager: SubscriptionManager
    
    init(commandPrefix: String, registry: CommandRegistry, manager: SubscriptionManager) {
        self.commandPrefix = commandPrefix
        self.registry = registry
        self.manager = manager
    }

    func handle(message: Message, from client: MessageClient) -> Bool {
        guard !manager.isEmpty, let channelId = message.channelId else { return false }

		let output = MessageIOOutput(client: client, defaultTextChannelId: channelId)
		let isBot = message.author?.bot ?? false

        manager.notifySubscriptions(on: message.channelId, isBot: isBot) {
            let context = CommandContext(
                client: client,
                registry: registry,
                message: message,
                commandPrefix: commandPrefix,
                subscriptions: $1
            )
            registry[$0]?.onSubscriptionMessage(withContent: message.content, output: output, context: context)
        }
        
        return true
    }
}
