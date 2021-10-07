public class PronounsCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Lets the user pick pronouns to be displayed as a role",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        // TODO
    }
}
