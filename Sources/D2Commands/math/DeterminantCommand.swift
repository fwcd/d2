import D2Utils

public class DeterminantCommand: Command {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Computes a determinant",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .ndArrays
    public let outputValueType: RichValueType = .ndArrays
    private let sizeLimit: Int

    public init(sizeLimit: Int = 5) {
        self.sizeLimit = sizeLimit
    }
    
    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let matrix = input.asNDArrays?.first?.asMatrix else {
            output.append(errorText: "Please input a matrix")
            return
        }
        guard matrix.isSquare else {
            output.append(errorText: "The determinant is only defined for square matrices")
            return
        }

        output.append(.ndArrays([NDArray(matrix.determinant)]))
    }
}