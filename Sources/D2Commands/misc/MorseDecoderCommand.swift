public class MorseDecoderCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Morse-decodes a string",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        output.append(morseDecode(input))
    }
}
