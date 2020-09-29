import Utils

public class StreamerRoleCommand: Command {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Configures a role to auto-assign to streamers",
        requiredPermissionLevel: .admin
    )
    @AutoSerializing private var streamerRoleConfiguration: StreamerRoleConfiguration

    public init(streamerRoleConfiguration: AutoSerializing<StreamerRoleConfiguration>) {
        self._streamerRoleConfiguration = streamerRoleConfiguration
    }

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let guild = context.guild else {
            output.append(errorText: "Not on a guild")
            return
        }

        if let role = input.asRoleMentions?.first {
            streamerRoleConfiguration.streamerRoles[guild.id] = role
            output.append("Successfully set the Twitch streamer role!")
        } else {
            let roleId = streamerRoleConfiguration.streamerRoles[guild.id]
            let roleName = roleId.flatMap { guild.roles[$0] }?.name ?? "none"
            output.append("The Twitch streamer role on this guild is currently `\(roleName)`")
        }
    }
}
