import Logging
import D2MessageIO
import D2Commands

fileprivate let log = Logger(label: "D2Handlers.SubscriptionHandler")

/// Handles messages from command subscriptions.
public struct SubscriptionHandler: MessageHandler {
    private let commandPrefix: String
    private let registry: CommandRegistry
    private let manager: SubscriptionManager

    public init(commandPrefix: String, registry: CommandRegistry, manager: SubscriptionManager) {
        self.commandPrefix = commandPrefix
        self.registry = registry
        self.manager = manager
    }

    public func handle(message: Message, from client: any MessageClient) -> Bool {
        guard !manager.isEmpty, let channelId = message.channelId else { return false }

        let isBot = message.author?.bot ?? false
        var handled = false

        manager.notifySubscriptions(on: channelId, isBot: isBot) { name, subs in
            let context = CommandContext(
                client: client,
                registry: registry,
                message: message,
                commandPrefix: commandPrefix,
                subscriptions: subs
            )
            let command = registry[name]
            let output = MessageIOOutput(context: context) { sentMessages in
                for sent in sentMessages {
                    command?.onSuccessfullySent(context: CommandContext(
                        client: client,
                        registry: self.registry,
                        message: sent,
                        commandPrefix: self.commandPrefix,
                        subscriptions: subs
                    ))
                }
            }
            command?.onSubscriptionMessage(with: message.content, output: output, context: context)
            handled = true
        }

        return handled
    }
}
