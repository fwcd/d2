public class MorseEncoderCommand: StringCommand {
    public let info = CommandInfo(
        category: .coding,
        shortDescription: "Morse-encodes a string",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        output.append(morseEncode(input))
    }
}
