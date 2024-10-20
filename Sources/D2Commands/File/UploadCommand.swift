import Foundation
import Utils
import D2MessageIO

public class UploadCommand: Command {
    public let info = CommandInfo(
        category: .file,
        shortDescription: "Uploads a file to a path relative to D2's pwd",
        helpText: "Pipe a file path into an invocation of upload, e.g. `... | upload local/test.txt`",
        requiredPermissionLevel: .admin
    )
    public let inputValueType: RichValueType = .compound([.text, .attachments])
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let filePath = input.asText else {
            await output.append(errorText: info.helpText!)
            return
        }
        guard let attachment = input.asAttachments?.first else {
            await output.append(errorText: "Please attach a file to upload!")
            return
        }

        do {
            let data = try await attachment.download()
            let url = URL(fileURLWithPath: filePath)
            try data.write(to: url)
            await output.append("Successfully wrote \(attachment.size) \("byte".pluralized(with: attachment.size))!")
        } catch {
            await output.append(error, errorText: "Could not download attachment")
        }
    }
}
