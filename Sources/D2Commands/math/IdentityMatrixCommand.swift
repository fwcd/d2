import D2Utils

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

    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let size = input.asText.flatMap({ Int($0) }) else {
            output.append(errorText: "Please specify a single integer as size!")
            return
        }
        guard size <= sizeLimit else {
            output.append(errorText: "Please use a smaller size!")
            return
        }
        guard size >= 0 else {
            output.append(errorText: "Please use a non-negative size!")
            return 
        }

        output.append(.ndArrays([Matrix.identity(width: size).asNDArray]))
    }
}