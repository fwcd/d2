import NIO
import D2MessageIO
import D2Permissions
import D2Commands

public struct MIOCommandInteractionHandler: InteractionHandler {
    private let registry: CommandRegistry
    private let hostInfo: HostInfo
    private let permissionManager: PermissionManager
    private let eventLoopGroup: any EventLoopGroup

    public init(registry: CommandRegistry, hostInfo: HostInfo, permissionManager: PermissionManager, eventLoopGroup: any EventLoopGroup) {
        self.registry = registry
        self.hostInfo = hostInfo
        self.permissionManager = permissionManager
        self.eventLoopGroup = eventLoopGroup
    }

    public func handle(interaction: Interaction, client: any Sink) -> Bool {
        guard
            interaction.type == .mioCommand,
            let data = interaction.data,
            let invocation = data.options.first else { return false }

        let content = invocation.options.compactMap { $0.value as? String }.joined(separator: " ")
        let input = RichValue.text(content)
        let context = CommandContext(
            client: client,
            registry: registry,
            message: Message(
                content: content,
                author: interaction.member?.user,
                channelId: interaction.channelId,
                guild: interaction.guildId.flatMap(client.guild(for:)),
                guildMember: interaction.member
            ),
            commandPrefix: "/", // TODO: Find a more elegant solution than hardcoding the slash
            hostInfo: hostInfo,
            subscriptions: .init(), // TODO: Support subscriptions here
            eventLoopGroup: eventLoopGroup
        )
        let output = MessageIOInteractionOutput(interaction: interaction, context: context)

        guard let author = interaction.member?.user else {
            output.append(errorText: "The interaction must have an author!")
            return true
        }
        guard let command = registry[invocation.name] else {
            output.append(errorText: "Unknown command name `\(invocation.name)`")
            return true
        }
        guard permissionManager.user(author, hasPermission: command.info.requiredPermissionLevel, usingSimulated: command.info.usesSimulatedPermissionLevel) else {
            output.append(errorText: "Insufficient permissions, sorry. :(")
            return true
        }

        command.invoke(with: input, output: output, context: context)
        return true
    }
}
