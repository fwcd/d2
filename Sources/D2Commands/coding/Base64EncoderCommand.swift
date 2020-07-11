public class Base64EncoderCommand: Command {
    public let info = CommandInfo(
        category: .coding,
        shortDescription: "Encodes data using Base64",
        longDescription: "Encodes text (utf8) or images (png) using Base64",
        requiredPermissionLevel: .vip
    )
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        do {
            guard let data = try input.asImage?.pngEncoded() ?? input.asText?.data(using: .utf8), !data.isEmpty else {
                output.append(errorText: "Please append some text or an image to encode!")
                return
            }

            let encoded = data.base64EncodedString()
            guard encoded.count < 4000 else {
                output.append(errorText: "Your encoded data is too long!")
                return
            }
            output.append(encoded)
        } catch {
            output.append(error, errorText: "Something went wrong while Base64-encoding")
        }
    }
}
