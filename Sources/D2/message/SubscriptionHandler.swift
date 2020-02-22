import SwiftDiscord
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

    func handle(message: DiscordMessage, from client: DiscordClient) -> Bool {
        guard !manager.isEmpty else { return false }

		let output = DiscordOutput(client: client, defaultTextChannel: message.channel)
		let context = CommandContext(
			guild: client.guildForChannel(message.channelId),
			registry: registry,
			message: message,
            commandPrefix: commandPrefix
		)
		let isBot = message.author.bot
	
        manager.notifySubscriptions(on: message.channelId, isBot: isBot) {
            $0.command.onSubscriptionMessage(withContent: message.content, output: output, context: context)
        }
        
        return true
    }
}
