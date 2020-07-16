import D2Utils

public class TwitchRoleCommand: Command {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Configures a role to auto-assign to streamers",
        requiredPermissionLevel: .admin
    )
    private let twitchRoleConfiguration: AutoSerializing<TwitchRoleConfiguration>

    public init(twitchRoleConfiguration: AutoSerializing<TwitchRoleConfiguration>) {
        self.twitchRoleConfiguration = twitchRoleConfiguration
    }

    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let guild = context.guild else {
            output.append(errorText: "Not on a guild")
            return
        }

        if let role = input.asRoleMentions?.first {
            twitchRoleConfiguration.wrappedValue.twitchRoles[guild.id] = role
            output.append("Successfully set the Twitch streamer role!")
        } else {
            let roleId = twitchRoleConfiguration.wrappedValue.twitchRoles[guild.id]
            let roleName = roleId.flatMap { guild.roles[$0] }?.name ?? "none"
            output.append("The Twitch streamer role on this guild is currently `\(roleName)`")
        }
    }
}
