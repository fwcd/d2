import Utils

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

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let matrix = input.asNDArrays?.first?.asMatrix else {
            await output.append(errorText: "Please input a matrix")
            return
        }
        guard matrix.isSquare else {
            await output.append(errorText: "The inverse is only defined for square matrices")
            return
        }
        guard let inverse = matrix.inverse else {
            await output.append(errorText: "The given matrix has no inverse")
            return
        }

        await output.append(.ndArrays([inverse.asNDArray]))
    }
}
