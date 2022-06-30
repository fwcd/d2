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

        output.append("Generating an image... (could take a minute or two)")

        DallEMiniQuery(prompt: input).perform().listen {
            do {
                let result = try $0.get()
                guard !result.images.isEmpty else {
                    output.append(errorText: "DALL-E generated no images")
                    return
                }
                let files = result.decodedJpegImages.map {
                    Message.FileUpload(data: $0, filename: "dallemini-result.jpg", mimeType: "image/jpeg")
                }
                guard !files.isEmpty else {
                    output.append(errorText: "DALL-E images could not be decoded")
                    return
                }
                output.append(.files(files))
            } catch {
                output.append(error, errorText: "Could not query DALL-E result")
            }
        }
    }
}
