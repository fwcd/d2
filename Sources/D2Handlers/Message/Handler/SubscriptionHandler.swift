import Logging
import NIO
import D2MessageIO
import D2Commands

private let log = Logger(label: "D2Handlers.SubscriptionHandler")

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

    public func handle(message: Message, sink: any Sink) async -> Bool {
        guard !manager.isEmpty, let channelId = message.channelId else { return false }

        let isBot = message.author?.bot ?? false
        var handled = false

        await manager.notifySubscriptions(on: channelId, isBot: isBot) { name, subs in
            let context = CommandContext(
                sink: sink,
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
                    await command?.onSuccessfullySent(context: CommandContext(
                        sink: sink,
                        registry: registry,
                        message: sent,
                        commandPrefix: commandPrefix,
                        hostInfo: hostInfo,
                        subscriptions: subs,
                        eventLoopGroup: eventLoopGroup
                    ))
                }
            }
            await command?.onSubscriptionMessage(with: message.content, output: output, context: context)
            handled = true
        }

        return handled
    }
}
