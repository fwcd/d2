import Utils

public class TableToNDArrayCommand: Command {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Converts a table to an ND array",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .table
    public let outputValueType: RichValueType = .ndArrays

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let table = input.asTable else {
            output.append(errorText: "Please input a table for conversion!")
            return
        }
        do {
            output.append(.ndArrays([
                try .init(table.map { row in row.compactMap { Rational($0)?.reduced() } })
            ]))
        } catch {
            output.append(error, errorText: "Could not create ND array")
        }
    }
}
