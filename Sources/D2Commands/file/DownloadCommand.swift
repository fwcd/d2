import Foundation
import D2Utils
import D2MessageIO

public class DownloadCommand: Command {
    public let info = CommandInfo(
        category: .file,
        shortDescription: "Downloads a file to a path relative to D2's pwd",
        helpText: "Pipe a file path into an invocation of upload, e.g. `... | download local/test.txt`",
        requiredPermissionLevel: .admin
    )
    public let inputValueType: RichValueType = .text
    public let outputValueType: RichValueType = .compound([.text, .files])

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let filePath = input.asText else {
            output.append(errorText: info.helpText!)
            return
        }

        do {
            let url = URL(fileURLWithPath: filePath)
            let data = try Data(contentsOf: url)
            output.append(.files([Message.FileUpload(data: data, filename: url.lastPathComponent, mimeType: "application/octet-stream")]))
        } catch {
            output.append(error, errorText: "Could not download file")
        }
    }
}
