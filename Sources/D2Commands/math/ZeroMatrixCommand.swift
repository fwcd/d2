import D2Utils

public class ZeroMatrixCommand: Command {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "The zero matrix",
        helpText: "Syntax: [size]",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let size = input.asText.flatMap({ Int($0) }) else {
            output.append(errorText: "Please specify a single integer as size!")
            return
        }

        output.append(.ndArrays([Matrix.zero(width: size, height: size).asNDArray]))
    }
}