public class DebugMessageCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Outputs a debug description of the invocation message",
        requiredPermissionLevel: .vip
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        output.append(.code("\(context.message)", language: "swift"))
    }
}
