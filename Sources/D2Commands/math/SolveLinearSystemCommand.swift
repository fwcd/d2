import Utils

public class SolveLinearSystemCommand: Command {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Solves a linear system of equations",
        longDescription: "Solves a linear system of equations and outputs the resulting point. Note that only points are supported currently (i.e. the matrix' rows must be linearly independent)",
        helpText: "Syntax: [augmented input matrix]",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .ndArrays
    public let outputValueType: RichValueType = .ndArrays
    private let sizeLimit: Int

    public init(sizeLimit: Int = 8) {
        self.sizeLimit = sizeLimit
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        guard let matrix = input.asNDArrays?.first?.asMatrix else {
            output.append(errorText: "Please input a matrix")
            return
        }
        guard matrix.width == matrix.height + 1 else {
            output.append(errorText: "The matrix should have the shape of an augmented matrix (i.e. be one column wider than a square matrix).")
            return
        }
        let cols = matrix.columns
        let a = Matrix(Array(cols.dropLast())).transpose
        let b = Matrix(columnVector: cols.last!)

        guard let aInverted = a.inverse else {
            output.append(errorText: "Linearly dependent equations are currently not supported")
            return
        }

        output.append(.ndArrays([(aInverted * b).asNDArray]))
    }
}
