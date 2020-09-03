public class RowEcholonFormCommand: Command {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Brings a matrix into row-echolon form through Gauss elimination",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .ndArrays
    public let outputValueType: RichValueType = .ndArrays

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let matrix = input.asNDArrays?.first?.asMatrix else {
            output.append(errorText: "Please input a matrix")
            return
        }
        guard let rowEcholon = matrix.rowEcholonForm else {
            output.append(errorText: "The given matrix cannot be converted into row-echolon-form")
            return
        }

        output.append(.ndArrays([rowEcholon.asNDArray]))
    }
}
