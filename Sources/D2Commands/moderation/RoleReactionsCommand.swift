import Utils

public class RoleReactionsCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Adds reactions to a message that automatically assign roles",
        requiredPermissionLevel: .vip
    )
    @AutoSerializing private var configuration: RoleReactionsConfiguration

    public init(configuration: AutoSerializing<RoleReactionsConfiguration>) {
        self._configuration = configuration
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        // TODO
    }
}
