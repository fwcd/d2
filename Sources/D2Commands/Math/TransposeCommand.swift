import Utils

public class TransposeCommand: Command {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Transposes a matrix",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .ndArrays
    public let outputValueType: RichValueType = .ndArrays
    private let sizeLimit: Int

    public init(sizeLimit: Int = 16) {
        self.sizeLimit = sizeLimit
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        guard let matrix = input.asNDArrays?.first?.asMatrix else {
            output.append(errorText: "Please input a matrix")
            return
        }

        output.append(.ndArrays([matrix.transpose.asNDArray]))
    }
}
