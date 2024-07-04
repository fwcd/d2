import Utils

public class OrthogonalizeCommand: Command {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Orthogonalizes a matrix",
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
            await output.append(errorText: "Orthogonalization is only defined for square matrices")
            return
        }

        let columns = matrix.columnVectors
        guard let first = columns.first else {
            await output.append(errorText: "Your matrix does not contain a single column")
            return
        }

        var orthos = [first]

        // Orthogonalize the vectors using Gram-Schmidt
        for column in columns.dropFirst() {
            orthos.append(column + orthos.map { -column.projected(onto: $0) }.reduce(Vector.zero(size: matrix.height), +))
        }

        // Normalize the vectors
        orthos = orthos.map { $0 / Rational(approximately: $0.magnitude) }

        await output.append(.ndArrays([Matrix(orthos.map { $0.values }).transpose.asNDArray]))
    }
}
