public class YoCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Yo!",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        output.append("Yo!")
    }
}
