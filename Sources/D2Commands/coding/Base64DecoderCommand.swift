import CairoGraphics
import Foundation

public class Base64DecoderCommand: StringCommand {
    public let info = CommandInfo(
        category: .coding,
        shortDescription: "Decodes data using Base64",
        longDescription: "Decodes a Base64 string to an image (png) or text (utf8)",
        requiredPermissionLevel: .vip
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard let data = Data(base64Encoded: input) else {
            output.append(errorText: "Could not decode data as Base64")
            return
        }

        if let image = try? CairoImage(pngData: data) {
            do {
                try output.append(image)
            } catch {
                output.append(errorText: "Could not send image")
            }
        } else if let text = String(data: data, encoding: .utf8) {
            output.append(text)
        } else {
            output.append(errorText: "Data is neither a png image nor utf8-encoded text!")
        }
    }
}
