public class YoCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Yo!",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        output.append("Yo!")
    }
}
