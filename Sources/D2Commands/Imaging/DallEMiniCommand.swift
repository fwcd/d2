import D2MessageIO
import D2NetAPIs

public class DallEMiniCommand: StringCommand {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Generates an image from a text prompt using DALL-E mini",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter a text prompt!")
            return
        }

        await output.append("Generating an image... (could take a minute or two)")

        do {
            let result = try await DallEMiniQuery(prompt: input).perform()
            guard !result.images.isEmpty else {
                await output.append(errorText: "DALL-E generated no images")
                return
            }
            let files = result.decodedJpegImages.map {
                Message.FileUpload(data: $0, filename: "dallemini-result.jpg", mimeType: "image/jpeg")
            }
            guard !files.isEmpty else {
                await output.append(errorText: "DALL-E images could not be decoded")
                return
            }
            await output.append(.files(files))
        } catch {
            await output.append(error, errorText: "Could not query DALL-E result")
        }
    }
}
