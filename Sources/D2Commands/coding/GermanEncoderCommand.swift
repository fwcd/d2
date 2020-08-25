public class GermanEncoderCommand: StringCommand {
    public let info = CommandInfo(
        category: .coding,
        shortDescription: "Encodes a string into 'german'",
        requiredPermissionLevel: .basic
    )
    private let maxLength: Int

    public init(maxLength: Int = 35) {
        self.maxLength = maxLength
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard input.count <= maxLength else {
            output.append(errorText: "Please input a text of length <= \(maxLength)!")
            return
        }
        guard let data = input.data(using: .utf8) else {
            output.append(errorText: "Could not encode input as UTF-8")
            return
        }
        output.append(germanEncode(data))
    }
}
