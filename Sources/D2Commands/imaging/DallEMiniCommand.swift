import D2MessageIO
import D2NetAPIs

public class DallEMiniCommand: StringCommand {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Generates an image from a text prompt using DALL-E mini",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter a text prompt!")
            return
        }

        context.channel?.triggerTyping()
        DallEMiniQuery(prompt: input).perform().listen {
            do {
                let result = try $0.get()
                let files = result.decodedJpegImages.map {
                    Message.FileUpload(data: $0, filename: "dallemini-result.jpg", mimeType: "image/jpeg")
                }
                output.append(.files(files))
            } catch {
                output.append(error, errorText: "Could not query DALL-E result")
            }
        }
    }
}
