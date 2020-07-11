public class Base64EncoderCommand: Command {
    public let info = CommandInfo(
        category: .coding,
        shortDescription: "Encodes text or images using Base64",
        requiredPermissionLevel: .vip
    )

    public init() {}

    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        do {
            guard let data = try input.asImage?.pngEncoded() ?? input.asText?.data(using: .utf8), !data.isEmpty else {
                output.append(errorText: "Please append some text or an image to encode!")
                return
            }

            output.append(data.base64EncodedString().truncate(2000))
        } catch {
            output.append(error, errorText: "Something went wrong while Base64-encoding")
        }
    }
}
