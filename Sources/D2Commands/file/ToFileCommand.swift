import SwiftDiscord
import D2Permissions
import D2Utils

fileprivate let argsPattern = try! Regex(from: "(\\S+)\\s*([\\s\\S]*)")

// TODO: Use Arg API

public class ToFileCommand: Command {
	public let info = CommandInfo(
		category: .file,
		shortDescription: "Writes text to a file",
		longDescription: "Responds with a text file containing the input",
		helpText: "Syntax: [filename} [content]...",
		requiredPermissionLevel: .basic
	)
	public let inputValueType: RichValueType = .text
	public let outputValueType: RichValueType = .files
	
	public init() {}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		let combinedInput = input.asText ?? input.asCode ?? ""
		
		if let parsedArgs = argsPattern.firstGroups(in: combinedInput) {
			let filename = parsedArgs[1]
			let content = parsedArgs[2]
			
			guard let data = content.data(using: .utf8) else {
				output.append("Could not encode file data as UTF-8")
				return
			}
			
			output.append(.files([DiscordFileUpload(data: data, filename: filename, mimeType: "plain/text")]))
		} else {
			output.append(info.helpText!)
		}
	}
}
