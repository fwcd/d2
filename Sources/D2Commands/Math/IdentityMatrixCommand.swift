import Utils

public class IdentityMatrixCommand: Command {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "The identity matrix",
        helpText: "Syntax: [size]",
        requiredPermissionLevel: .basic
    )
    private let sizeLimit: Int

    public init(sizeLimit: Int = 8) {
        self.sizeLimit = sizeLimit
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let size = input.asText.flatMap({ Int($0) }) else {
            await output.append(errorText: "Please specify a single integer as size!")
            return
        }
        guard size <= sizeLimit else {
            await output.append(errorText: "Please use a smaller size!")
            return
        }
        guard size >= 0 else {
            await output.append(errorText: "Please use a non-negative size!")
            return
        }

        await output.append(.ndArrays([Matrix.identity(width: size).asNDArray]))
    }
}
