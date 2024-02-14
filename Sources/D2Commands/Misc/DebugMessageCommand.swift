public class DebugMessageCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Outputs a debug description of the invocation message",
        requiredPermissionLevel: .vip
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        var message = context.message
        message.guild = nil
        output.append(.code("\(message)", language: "swift"))
    }
}
