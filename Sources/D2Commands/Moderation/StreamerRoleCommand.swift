import Utils

public class StreamerRoleCommand: Command {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Configures a role to auto-assign to streamers",
        requiredPermissionLevel: .admin
    )
    @Binding private var streamerRoleConfiguration: StreamerRoleConfiguration

    public init(@Binding streamerRoleConfiguration: StreamerRoleConfiguration) {
        self._streamerRoleConfiguration = _streamerRoleConfiguration
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let guild = await context.guild else {
            await output.append(errorText: "Not on a guild")
            return
        }

        if let role = input.asRoleMentions?.first {
            streamerRoleConfiguration.streamerRoles[guild.id] = role
            await output.append("Successfully set the Twitch streamer role!")
        } else {
            let roleId = streamerRoleConfiguration.streamerRoles[guild.id]
            let roleName = roleId.flatMap { guild.roles[$0] }?.name ?? "none"
            await output.append("The Twitch streamer role on this guild is currently `\(roleName)`")
        }
    }
}
