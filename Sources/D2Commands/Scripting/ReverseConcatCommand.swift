import D2Permissions

public class ReverseConcatCommand: Command {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Concatenates the input values in reverse order",
        longDescription: "Concatenates a compound input in reverse order as text",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .compound([.text])
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        await output.append(input.values.compactMap { $0.asText }.reversed().joined(separator: " "))
    }
}
