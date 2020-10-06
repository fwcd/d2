public class ShapeCommand: Command {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Outputs the shape of the input nd-arrays",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .ndArrays

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let ndArrays = input.asNDArrays else {
            output.append(errorText: "Please input nd-arrays to fetch the shape(s)!")
            return
        }

        output.append(.compound(ndArrays.map { .text("\($0.shape)") }))
    }
}
