public class TableToTextCommand: Command {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Converts a table to text by concatenating rows with newlines and columns with spaces",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .table
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let table = input.asTable else {
            await output.append(errorText: "Please input a table!")
            return
        }

        await output.append(table.map { $0.joined(separator: " ") }.joined(separator: "\n"))
    }
}
