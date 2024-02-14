public class DoCommand: Command {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Passes an empty value",
        longDescription: "Ignores the input and passes an empty value. Useful for piping.",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        output.append(.none)
    }
}
