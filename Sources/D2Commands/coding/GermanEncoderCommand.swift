public class GermanEncoderCommand: StringCommand {
    public let info = CommandInfo(
        category: .coding,
        shortDescription: "Encodes a string into 'german'",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let data = input.data(using: .utf8) else {
            output.append(errorText: "Could not encode input as UTF-8")
            return
        }
        output.append(germanEncode(data))
    }
}
