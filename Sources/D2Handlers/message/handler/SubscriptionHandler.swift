import Logging
import NIO
import D2MessageIO
import D2Commands

fileprivate let log = Logger(label: "D2Handlers.SubscriptionHandler")

/// Handles messages from command subscriptions.
public struct SubscriptionHandler: MessageHandler {
    private let commandPrefix: String
    private let hostInfo: HostInfo
    private let registry: CommandRegistry
    private let manager: SubscriptionManager
    private let eventLoopGroup: any EventLoopGroup

    public init(commandPrefix: String, hostInfo: HostInfo, registry: CommandRegistry, manager: SubscriptionManager, eventLoopGroup: any EventLoopGroup) {
        self.commandPrefix = commandPrefix
        self.hostInfo = hostInfo
        self.registry = registry
        self.manager = manager
        self.eventLoopGroup = eventLoopGroup
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
                hostInfo: hostInfo,
                subscriptions: subs,
                eventLoopGroup: eventLoopGroup
            )
            let command = registry[name]
            let output = MessageIOOutput(context: context) { sentMessages in
                for sent in sentMessages {
                    command?.onSuccessfullySent(context: CommandContext(
                        client: client,
                        registry: registry,
                        message: sent,
                        commandPrefix: commandPrefix,
                        hostInfo: hostInfo,
                        subscriptions: subs,
                        eventLoopGroup: eventLoopGroup
                    ))
                }
            }
            command?.onSubscriptionMessage(with: message.content, output: output, context: context)
            handled = true
        }

        return handled
    }
}
