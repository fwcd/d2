import D2MessageIO
import D2Commands
import NIO

public struct SubscriptionInteractionHandler: InteractionHandler {
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

    public func handle(interaction: Interaction, sink: any Sink) async -> Bool {
        guard
            interaction.type == .messageComponent,
            let customId = interaction.data?.customId,
            let channelId = interaction.channelId,
            let member = interaction.member else { return false }
        let message = interaction.message ?? Message(content: "Dummy", channelId: channelId, id: MessageID("", clientName: sink.name))
        let user = member.user
        await manager.notifySubscriptions(on: channelId, isBot: user.bot) {
            let context = CommandContext(
                sink: sink,
                registry: registry,
                message: message,
                commandPrefix: commandPrefix,
                hostInfo: hostInfo,
                subscriptions: $1,
                eventLoopGroup: eventLoopGroup
            )
            let output = MessageIOInteractionOutput(interaction: interaction, context: context)
            await registry[$0]?.onSubscriptionInteraction(with: customId, by: user, output: output, context: context)
        }
        return true
    }
}
