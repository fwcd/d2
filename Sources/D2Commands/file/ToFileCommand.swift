import SwiftDiscord
import D2Permissions
import D2Utils

fileprivate let argsPattern = try! Regex(from: "(\\S+)\\s*([\\s\\S]*)")

public class ToFileCommand: Command {
	public let description = "Writes text to a file"
	public let inputValueType = "text"
	public let outputValueType = "files"
	public let helpText: String? = "Syntax: [filename] [content...]"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withArgs args: String, input: RichValue, output: CommandOutput, context: CommandContext) {
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
			output.append(helpText!)
		}
	}
}
