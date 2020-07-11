public class MorseEncoderCommand: StringCommand {
    public let info = CommandInfo(
        category: .coding,
        shortDescription: "Morse-encodes a string",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        output.append(morseEncode(input))
    }
}
