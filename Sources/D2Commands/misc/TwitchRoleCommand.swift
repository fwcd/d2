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
        // TODO
    }
}
