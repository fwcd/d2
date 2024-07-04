public class ShapeCommand: Command {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Outputs the shape of the input nd-arrays",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .ndArrays

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let ndArrays = input.asNDArrays else {
            await output.append(errorText: "Please input nd-arrays to fetch the shape(s)!")
            return
        }

        await output.append(.compound(ndArrays.map { .text("\($0.shape)") }))
    }
}
