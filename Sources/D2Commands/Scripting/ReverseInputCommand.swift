public class ReverseInputCommand: Command {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Reverses the order of the input",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .compound([])
    public let outputValueType: RichValueType = .compound([])

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        await output.append(.of(values: Array(input.values.reversed())))
    }
}
