import D2Permissions

public class ConcatCommand: StringCommand {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Concatenates the input values",
        longDescription: "Concatenates a compound input as text",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text
    private let separator = " "

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        output.append(input)
    }
}
