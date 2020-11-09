public class AddRoleReactionsCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Adds reactions to a message that automatically assign roles",
        requiredPermissionLevel: .vip
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        // TODO
    }
}
