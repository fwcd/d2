public class RowEcholonFormCommand: Command {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Brings a matrix into row-echolon form through Gauss elimination",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .ndArrays
    public let outputValueType: RichValueType = .ndArrays

    public init() {}

    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let matrix = input.asNDArrays?.first?.asMatrix else {
            output.append(errorText: "Please input a matrix")
            return
        }

        output.append(.ndArrays([matrix.rowEcholonForm.asNDArray]))
    }
}