import Utils

public class ColumnCommand: Command {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Fetches the nth column from a table",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .table
    public let outputValueType: RichValueType = .table

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        guard let table = input.asTable else {
            output.append(errorText: "Please input a table!")
            return
        }
        guard let raw = input.asText, let n = Int(raw) else {
            output.append(errorText: "Please input a number!")
            return
        }
        output.append(.table(table.compactMap { $0[safely: n].map { [$0] } ?? [] }))
    }
}
