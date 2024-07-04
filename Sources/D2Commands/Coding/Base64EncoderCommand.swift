public class Base64EncoderCommand: Command {
    public let info = CommandInfo(
        category: .coding,
        shortDescription: "Encodes data using Base64",
        longDescription: "Encodes text (utf8) or images (png) using Base64",
        requiredPermissionLevel: .vip
    )
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        do {
            guard let data = try input.asImage?.pngEncoded() ?? input.asText?.data(using: .utf8), !data.isEmpty else {
                await output.append(errorText: "Please append some text or an image to encode!")
                return
            }

            let encoded = data.base64EncodedString()
            guard encoded.count < 4000 else {
                await output.append(errorText: "Your encoded data is too long!")
                return
            }
            await output.append(encoded)
        } catch {
            await output.append(error, errorText: "Something went wrong while Base64-encoding")
        }
    }
}
