public class IdentityCommand: Command {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Appends the input to the output",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        output.append(input)
    }
}
