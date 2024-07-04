public class GermanEncoderCommand: StringCommand {
    public let info = CommandInfo(
        category: .coding,
        shortDescription: "Encodes a string into 'german'",
        requiredPermissionLevel: .basic
    )
    private let maxLength: Int

    public init(maxLength: Int = 200) {
        self.maxLength = maxLength
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard input.count <= maxLength else {
            await output.append(errorText: "Please input a text of length <= \(maxLength)!")
            return
        }
        guard let data = input.data(using: .utf8) else {
            await output.append(errorText: "Could not encode input as UTF-8")
            return
        }
        await output.append(germanEncode(data))
    }
}
