import D2Utils

public class StreamerRoleCommand: Command {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Configures a role to auto-assign to streamers",
        requiredPermissionLevel: .admin
    )
    private let streamerRoleConfiguration: AutoSerializing<StreamerRoleConfiguration>

    public init(streamerRoleConfiguration: AutoSerializing<StreamerRoleConfiguration>) {
        self.streamerRoleConfiguration = streamerRoleConfiguration
    }

    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let guild = context.guild else {
            output.append(errorText: "Not on a guild")
            return
        }

        if let role = input.asRoleMentions?.first {
            streamerRoleConfiguration.wrappedValue.streamerRoles[guild.id] = role
            output.append("Successfully set the Twitch streamer role!")
        } else {
            let roleId = streamerRoleConfiguration.wrappedValue.streamerRoles[guild.id]
            let roleName = roleId.flatMap { guild.roles[$0] }?.name ?? "none"
            output.append("The Twitch streamer role on this guild is currently `\(roleName)`")
        }
    }
}
