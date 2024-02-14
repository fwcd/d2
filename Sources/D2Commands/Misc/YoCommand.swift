public class YoCommand: VoidCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Yo!",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(output: any CommandOutput, context: CommandContext) {
        output.append("Yo!")
    }
}
