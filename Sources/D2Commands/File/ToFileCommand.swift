import D2MessageIO
import D2Permissions
import Utils

// TODO: Use Arg API

public class ToFileCommand: Command {
    public let info = CommandInfo(
        category: .file,
        shortDescription: "Writes text to a file",
        longDescription: "Responds with a text file containing the input",
        helpText: "Pipe a value into an invocation of tofile, e.g. `... | tofile test.txt`",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .text
    public let outputValueType: RichValueType = .files

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        if case let .compound(values) = input {
            guard let name = values.first else {
                await output.append(errorText: "Missing file name")
                return
            }

            guard let content = values[safely: 1] else {
                await output.append(errorText: "Missing content (try piping some value into this invocation)")
                return
            }

            guard let data = (content.asText ?? content.asCode ?? "").data(using: .utf8) else {
                await output.append(errorText: "Could not encode file data as UTF-8")
                return
            }

            await output.append(.files([Message.FileUpload(data: data, filename: name.asText ?? "", mimeType: "text/plain")]))
        } else {
            await output.append(errorText: info.helpText!)
        }
    }
}
