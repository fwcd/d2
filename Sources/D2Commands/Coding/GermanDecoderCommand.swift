public class GermanDecoderCommand: StringCommand {
    public let info = CommandInfo(
        category: .coding,
        shortDescription: "Decodes a 'german' string",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let decoded = String(data: germanDecode(input), encoding: .utf8) else {
            await output.append(errorText: "Data is not UTF-8 encoded!")
            return
        }
        await output.append(decoded)
    }
}
