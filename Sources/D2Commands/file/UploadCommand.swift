import Foundation
import D2Utils
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
    
    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let filePath = input.asText else {
            output.append(errorText: info.helpText!)
            return
        }
        guard let attachment = input.asAttachments?.first else {
            output.append(errorText: "Please attach a file to upload!")
            return
        }
        
        attachment.download {
            do {
                let data = try $0.get()
                let url = URL(fileURLWithPath: filePath)
                try data.write(to: url)
                output.append("Successfully wrote \(attachment.size) \("byte".pluralize(with: attachment.size))!")
            } catch {
                output.append(error, errorText: "Could not download attachment")
            }
        }
    }
}
