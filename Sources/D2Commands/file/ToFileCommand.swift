import SwiftDiscord
import D2Permissions
import D2Utils

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
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		if case let .compound(values) = input {
			guard let name = values.first else {
				output.append(errorText: "Missing file name")
				return
			}
			
			guard let content = values[safely: 1] else {
				output.append(errorText: "Missing content (try piping some value into this invocation)")
				return
			}

			guard let data = (content.asText ?? content.asCode ?? "").data(using: .utf8) else {
				output.append(errorText: "Could not encode file data as UTF-8")
				return
			}
			
			output.append(.files([DiscordFileUpload(data: data, filename: name.asText ?? "", mimeType: "plain/text")]))
		} else {
			output.append(info.helpText!)
		}
	}
}
