import D2Utils

public class InverseMatrixCommand: Command {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Computes the inverse of a matrix",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .ndArrays
    public let outputValueType: RichValueType = .ndArrays
    private let sizeLimit: Int

    public init(sizeLimit: Int = 16) {
        self.sizeLimit = sizeLimit
    }

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let matrix = input.asNDArrays?.first?.asMatrix else {
            output.append(errorText: "Please input a matrix")
            return
        }
        guard matrix.isSquare else {
            output.append(errorText: "The inverse is only defined for square matrices")
            return
        }
        guard let inverse = matrix.inverse else {
            output.append(errorText: "The given matrix has no inverse")
            return
        }

        output.append(.ndArrays([inverse.asNDArray]))
    }
}
