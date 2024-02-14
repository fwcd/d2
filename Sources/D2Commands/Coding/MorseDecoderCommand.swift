public class MorseDecoderCommand: StringCommand {
    public let info = CommandInfo(
        category: .coding,
        shortDescription: "Morse-decodes a string",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        output.append(morseDecode(input))
    }
}
